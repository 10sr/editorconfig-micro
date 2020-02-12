VERSION = "0.3.0"

local micro = import("micro")
local microBuffer = import("micro/buffer")
local config = import("micro/config")
local shell = import("micro/shell")

local verbose = config.GetGlobalOption("editorconfigverbose") or false

local function errlog(msg)
    -- TODO: automatically open the log buffer like plugin list
    microBuffer.Log(("editorconfig error: %s\n"):format(msg))
end

-- for debugging; use micro -debug, and then inspect log.txt
local function log(msg)
    micro.Log(("editorconfig debug: %s"):format(msg))
end

local function setSafely(key, value, buffer)
    if value == nil then
        -- log(("Ignore nil for %s"):format(key))
    else
        if config.GetGlobalOption(key) ~= value then
            log(("Set %s = %s"):format(key, value))
            buffer:SetOptionNative(key, value)
        end
    end
end

local function setIndentation(properties, buffer)
    local indent_size_str = properties["indent_size"]
    local tab_width_str = properties["tab_width"]
    local indent_style = properties["indent_style"]

    local indent_size = tonumber(indent_size_str, 10)
    local tab_width = tonumber(tab_width_str, 10)

    if indent_size_str == "tab" then
        indent_size = tab_width
    elseif tab_width == nil then
        tab_width = indent_size
    end

    if indent_style == "space" then
        setSafely("tabstospaces", true, buffer)
        setSafely("tabsize", indent_size, buffer)
    elseif indent_style == "tab" then
        setSafely("tabstospaces", false, buffer)
        setSafely("tabsize", tab_width, buffer)
    elseif indent_style ~= nil then
        errlog(("Unknown value for editorconfig property indent_style: %s"):format(indent_style or "nil"))
    end
end

local function setEndOfLine(properties, buffer)
    local end_of_line = properties["end_of_line"]
    if end_of_line == "lf" then
        setSafely("fileformat", "unix", buffer)
    elseif end_of_line == "crlf" then
        setSafely("fileformat", "dos", buffer)
    elseif end_of_line == "cr" then
        -- See https://github.com/zyedidia/micro/blob/master/runtime/help/options.md for supported runtime options.
        errlog(("Value %s for editorconfig property end_of_line is not currently supported by micro."):format(end_of_line))
    elseif end_of_line ~= nil then
        errlog(("Unknown value for editorconfig property end_of_line: %s"):format(end_of_line))
    end
end

local function setCharset(properties, buffer)
    local charset = properties["charset"]
    if charset ~= "utf-8" and charset ~= nil then
        -- TODO: I believe micro 2.0 added support for more charsets, so this is gonna have to be updated accordingly.
        -- Also now we need to actually set the charset since it isn't just utf-8.
        errlog(("Value %s for editorconfig property charset is not currently supported by micro."):format(charset))
    end
end

local function setTrimTrailingWhitespace(properties, buffer)
    local val = properties["trim_trailing_whitespace"]
    if val == "true" then
        setSafely("rmtrailingws", true, buffer)
    elseif val == "false" then
        setSafely("rmtrailingws", false, buffer)
    elseif val ~= nil then
        errlog(("Unknown value for editorconfig property trim_trailing_whitespace: %s"):format(val))
    end
end

local function setInsertFinalNewline(properties, buffer)
    local val = properties["insert_final_newline"]
    if val == "true" then
        setSafely("eofnewline", true, buffer)
    elseif val == "false" then
        setSafely("eofnewline", false, buffer)
    elseif val ~= nil then
        errlog(("Unknown value for editorconfig property insert_final_newline: %s"):format(val))
    end
end

local function applyProperties(properties, buffer)
    setIndentation(properties, buffer)
    setEndOfLine(properties, buffer)
    setCharset(properties, buffer)
    setTrimTrailingWhitespace(properties, buffer)
    setInsertFinalNewline(properties, buffer)
end

function onEditorConfigExit(output, args)
    if verbose then
        log(("Output: \n%s"):format(output))
    end

    local properties = {}
    for line in output:gmatch('([^\n]+)') do
        local key, value = line:match('([^=]*)=(.*)')
        if key == nil or value == nil then
            errlog(("Failed to parse editorconfig output: %s"):format(line))
            return
        end
        key = key:gsub('^%s(.-)%s*$', '%1')
        value = value:gsub('^%s(.-)%s*$', '%1')
        properties[key] = value
    end

    local buffer = args[1]
    applyProperties(properties, buffer)

    if verbose then
        log("Running editorconfig done")
    end
end

function getApplyProperties(bufpane)
    buffer = bufpane.Buf
    if (buffer.Path or "") == "" then
        -- Current buffer does not visit any file
        return
    end

    local fullpath = buffer.AbsPath
    if fullpath == nil then
        messenger:Message("editorconfig: AbsPath is empty")
        return
    end

    if verbose then;
        log(("Running editorconfig %s"):format(fullpath))
    end

    shell.JobSpawn("editorconfig", {fullpath}, nil, nil, onEditorConfigExit, buffer)
end

function onBufPaneOpen(bp)
    getApplyProperties(bp)
end

function onSave(bp)
    getApplyProperties(bp)
    return true
end

function init()
    config.MakeCommand("editorconfig", getApplyProperties, config.NoComplete)
    config.AddRuntimeFile("editorconfig", config.RTHelp, "help/editorconfig.md")
end
