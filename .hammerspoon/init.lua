-- 
-- Windowサイズの調整
-- 
hs.window.animationDuration = 0
units = {
  right50   = { key = 'right', pos = { x = 0.50, y = 0.00, w = 0.50, h = 1.00 } },
  left50    = { key = 'left',  pos = { x = 0.00, y = 0.00, w = 0.50, h = 1.00 } },
  top50     = { key = 'up',    pos = { x = 0.00, y = 0.00, w = 1.00, h = 0.50 } },
  bot50     = { key = 'down',  pos = { x = 0.00, y = 0.50, w = 1.00, h = 0.50 } },
  maximum   = { key = 'm',     pos = { x = 0.00, y = 0.00, w = 1.00, h = 1.00 } },
  topleft   = { key = '1',     pos = { x = 0.00, y = 0.00, w = 0.50, h = 0.50 } },
  topright  = { key = '2',     pos = { x = 0.50, y = 0.00, w = 0.50, h = 0.50 } },
  botleft   = { key = '3',     pos = { x = 0.00, y = 0.50, w = 0.50, h = 0.50 } },
  botright  = { key = '4',     pos = { x = 0.50, y = 0.50, w = 0.50, h = 0.50 } },
}

function moveFocusedWindow(position)
  return function()
    hs.window.focusedWindow():move(position, nil, true)
  end
end

mash = {'ctrl', 'option', 'cmd'}
for _, unit in pairs(units) do
  hs.hotkey.bind(mash, unit.key, moveFocusedWindow(unit.pos))
end



--
-- ctrl + [ で escape & 日本語入力をOff
--   1. 日本語入力途中でも確実にモード切り替えするために2回escape
--   2. 3回目のescapeでins modeからcmd modeに切り替え
--   3. ctrl + shift + ; はIME切り替えのショートカット（MacのIMEの機能）
--   4. 最後に ';' がバッファに残ることがあるので、escape で削除する
--  
--   Escapeキーで同じことをすると、Escapeが再起的に呼ばれ、無限ループに陥るため注意
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