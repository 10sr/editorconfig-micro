VERSION = "0.2.3"

local verbose = GetOption("editorconfigverbose") or false

local function logger(msg, view)
    messenger:AddLog(("EditorConfig <%s>: %s"):
            format(view.Buf.GetName(view.Buf), msg))
end

local function msg(msg, view)
    messenger:Message(("EditorConfig <%s>: %s"):
            format(view.Buf.GetName(view.Buf), msg))
end

local function setSafely(key, value, view)
    if value == nil then
        -- logger(("Ignore nil for %s"):format(key), view)
    else
        if GetOption(key) ~= value then
            logger(("Set %s = %s"):format(key, value), view)
            SetLocalOption(key, value, view)
        end
    end
end


local function setIndentation(properties, view)
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
        setSafely("tabstospaces", true, view)
        setSafely("tabsize", indent_size, view)
    elseif indent_style == "tab" then
        setSafely("tabstospaces", false, view)
        setSafely("tabsize", tab_width, view)
    elseif indent_style ~= nil then
        logger(("Unknown value for editorconfig property indent_style: %s"):format(indent_style or "nil"), view)
    end
end

local function setEndOfLine(properties, view)
    local end_of_line = properties["end_of_line"]
    if end_of_line == "lf" then
        setSafely("fileformat", "unix", view)
    elseif end_of_line == "crlf" then
        setSafely("fileformat", "dos", view)
    elseif end_of_line == "cr" then
        -- See https://github.com/zyedidia/micro/blob/master/runtime/help/options.md for supported runtime options.
        msg(("Value %s for editorconfig property end_of_line is not currently supported by micro."):format(end_of_line), view)
    elseif end_of_line ~= nil then
        msg(("Unknown value for editorconfig property end_of_line: %s"):format(end_of_line), view)
    end
end

local function setCharset(properties, view)
    local charset = properties["charset"]
    if charset ~= "utf-8" and charset ~= nil then
        msg(("Value %s for editorconfig property charset is not currently supported by micro."):format(charset), view)
    end
end

local function setTrimTrailingWhitespace(properties, view)
    local val = properties["trim_trailing_whitespace"]
    if val == "true" then
        setSafely("rmtrailingws", true, view)
    elseif val == "false" then
        setSafely("rmtrailingws", false, view)
    elseif val ~= nil then
        logger(("Unknown value for editorconfig property trim_trailing_whitespace: %s"):format(val), view)
    end
end

local function setInsertFinalNewline(properties, view)
    local val = properties["insert_final_newline"]
    if val == "true" then
        setSafely("eofnewline", true, view)
    elseif val == "false" then
        setSafely("eofnewline", false, view)
    elseif val ~= nil then
        logger(("Unknown value for editorconfig property insert_final_newline: %s"):format(val), view)
    end
end

local function applyProperties(properties, view)
    setIndentation(properties, view)
    setEndOfLine(properties, view)
    setCharset(properties, view)
    setTrimTrailingWhitespace(properties, view)
    setInsertFinalNewline(properties, view)
end

function onEditorConfigExit(output)
    local view = CurView()
    if verbose then
        logger(("Output: \n%s"):format(output), view)
    end
    local properties = {}
    for line in output:gmatch('([^\n]+)') do
        local key, value = line:match('([^=]*)=(.*)')
        if key == nil or value == nil then
            msg(("Failed to parse editorconfig output: %s"):
                    format(line), view)
            return
        end
        key = key:gsub('^%s(.-)%s*$', '%1')
        value = value:gsub('^%s(.-)%s*$', '%1')
        properties[key] = value
    end

    applyProperties(properties, view)
    if verbose then
        logger("Running editorconfig done", view)
    end
end

function getApplyProperties(view)
    view = view or CurView()

    if (view.Buf.Path or "") == "" then
        -- Current buffer does not visit any file
        return
    end

    local fullpath = view.Buf.AbsPath
    if fullpath == nil then
        messenger:Message("editorconfig: AbsPath is empty")
        return
    end

    if verbose then
        logger(("Running editorconfig %s"):format(fullpath), view)
    end
    JobSpawn("editorconfig", {fullpath}, "", "", "editorconfig.onEditorConfigExit")
end

function onOpenFile(view)
    getApplyProperties(view)
end

function onViewOpen(view)
    getApplyProperties(view)
end

function onSave(view)
    getApplyProperties(view)
end

MakeCommand("editorconfig", "editorconfig.getApplyProperties")
AddRuntimeFile("editorconfig", "help", "help/editorconfig.md")
