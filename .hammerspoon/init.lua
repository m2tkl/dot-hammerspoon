-- 
-- Windowサイズの調整
-- 
hs.window.animationDuration = 0
units = {
  right50       = { x = 0.50, y = 0.00, w = 0.50, h = 1.00 },
  left50        = { x = 0.00, y = 0.00, w = 0.50, h = 1.00 },
  top50         = { x = 0.00, y = 0.00, w = 1.00, h = 0.50 },
  bot50         = { x = 0.00, y = 0.50, w = 1.00, h = 0.50 },
  maximum       = { x = 0.00, y = 0.00, w = 1.00, h = 1.00 },
  topleft       = { x = 0.00, y = 0.00, w = 0.50, h = 0.50 },
  topright      = { x = 0.50, y = 0.00, w = 0.50, h = 0.50 },
  botleft    = { x = 0.00, y = 0.50, w = 0.50, h = 0.50 },
  botright   = { x = 0.50, y = 0.50, w = 0.50, h = 0.50 }
}

mash = {'option', 'ctrl', 'cmd'}
hs.hotkey.bind(mash, 'right', function() hs.window.focusedWindow():move(units.right50, nil, true) end)
hs.hotkey.bind(mash, 'left',  function() hs.window.focusedWindow():move(units.left50, nil, true) end)
hs.hotkey.bind(mash, 'up',    function() hs.window.focusedWindow():move(units.top50, nil, true) end)
hs.hotkey.bind(mash, 'down',  function() hs.window.focusedWindow():move(units.bot50, nil, true) end)
hs.hotkey.bind(mash, 'm',     function() hs.window.focusedWindow():move(units.maximum, nil, true) end)
hs.hotkey.bind(mash, '1',     function() hs.window.focusedWindow():move(units.topleft, nil, true) end)
hs.hotkey.bind(mash, '2',     function() hs.window.focusedWindow():move(units.topright, nil, true) end)
hs.hotkey.bind(mash, '3',     function() hs.window.focusedWindow():move(units.botleft, nil, true) end)
hs.hotkey.bind(mash, '4',     function() hs.window.focusedWindow():move(units.botright, nil, true) end)


--
-- ctrl + [ で escape & 日本語入力をOff
--   日本語入力途中でも確実にモード切り替えするために2回escape
--   3回目のescapeでins modeからcmd modeに切り替え
--   ctrl + shift + ; はIME切り替えのショートカット（MacのIMEの機能）
--   最後に ';' がバッファに残ることがあるので、escape で削除する
--
hs.hotkey.bind({'ctrl'}, '[', function()
  for i = 1, 3 do hs.eventtap.keyStroke({}, 'escape', 1000) end
  hs.eventtap.keyStroke({'ctrl', 'shift'}, ';', 1000)
  hs.eventtap.keyStroke({}, 'escape', 1000)
end)


--
-- Reload config
--
hs.hotkey.bind({'cmd', 'option', 'ctrl'}, 'r', function()
  hs.reload()
end)


-- 
-- Scroll by Mouse Dragging
-- Reference
--  - https://qiita.com/zyyx-matsushita/items/070f7e9d021ac099b5e2
--

local deferred = false

overrideRightMouseDown = hs.eventtap.new({ hs.eventtap.event.types.rightMouseDown }, function(e)
    --print("down"))
    deferred = true
    return true
end)

overrideRightMouseUp = hs.eventtap.new({ hs.eventtap.event.types.rightMouseUp }, function(e)
    -- print("up"))
    if (deferred) then
        overrideRightMouseDown:stop()
        overrideRightMouseUp:stop()
        hs.eventtap.rightClick(e:location())
        overrideRightMouseDown:start()
        overrideRightMouseUp:start()
        return true
    end

    return false
end)

local oldmousepos = {}
local scrollmult = -4   -- negative multiplier makes mouse work like traditional scrollwheel
dragRightToScroll = hs.eventtap.new({ hs.eventtap.event.types.rightMouseDragged }, function(e)
    -- print("scroll");

    deferred = false

    oldmousepos = hs.mouse.getAbsolutePosition()    

    local dx = e:getProperty(hs.eventtap.event.properties['mouseEventDeltaX'])
    local dy = e:getProperty(hs.eventtap.event.properties['mouseEventDeltaY'])
    local scroll = hs.eventtap.event.newScrollEvent({-dx * scrollmult, -dy * scrollmult},{},'pixel')

    -- put the mouse back
    hs.mouse.setAbsolutePosition(oldmousepos)

    return true, {scroll}
end)

overrideRightMouseDown:start()
overrideRightMouseUp:start()
dragRightToScroll:start()