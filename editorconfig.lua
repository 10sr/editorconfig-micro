VERSION = "0.1.1"

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
        logger(("Set %s = %s"):format(key, value), view)
        SetLocalOption(key, value, view)
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
        setSafely("tabstospaces", "on", view)
        setSafely("tabsize", indent_size, view)
    elseif indent_style == "tab" then
        setSafely("tabstospaces", "off", view)
        setSafely("tabsize", tab_width, view)
    else
        logger(("Unknown indent_style: %s"):format(indent_style or "nil"), view)
        setSafely("tabsize", indent_size, view)
    end
end

local function setCodingSystem(properties, view)
    -- Currently micro does not support changing coding-systems
    -- (Always use utf-8 with LF?)
    local end_of_line = properties["end_of_line"]
    local charset = properties["charset"]
    if not (end_of_line == nil or end_of_line == "lf") then
        msg(("Unsupported end_of_line: %s"):format(end_of_line), view)
    end
    if not (charset == nil or charset == "utf-8") then
        msg(("Unsupported charset: %s"):format(charset), view)
    end

end

local function setInsertFinalNewline(properties, view)
    local val = properties["insert_final_newline"]
    if val == "true" then
        setSafely("eofnewline", true, view)
    elseif val == "false" then
        setSafely("eofnewline", false, view)
    else
        logger(("Unknown insert_final_newline: %s"):format(val), view)
    end
end

local function applyProperties(properties, view)
    setIndentation(properties, view)
    setCodingSystem(properties, view)
    -- `ruler' is not what we want!
    -- setMaxLineLength(properties, view)
    -- setTrimTrailingWhitespace(properties, view)
    setInsertFinalNewline(properties, view)
end

function onEditorConfigExit(output)
    local view = CurView()
    logger(("Output: \n%s"):format(output), view)
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
    logger("Running editorconfig done", view)
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

    logger(("Running editorconfig %s"):format(fullpath), view)
    JobSpawn("editorconfig", {fullpath}, "", "", "editorconfig.onEditorConfigExit")
end

function onOpenFile(view)
    getApplyProperties(view)
end

function onViewOpen(view)
    getApplyProperties(view)
end

function onSave(view)
end

MakeCommand("editorconfig", "editorconfig.getApplyProperties")
AddRuntimeFile("editorconfig", "help", "help/editorconfig.md")
