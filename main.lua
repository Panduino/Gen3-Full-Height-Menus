-- Standalone FireRed/LeafGreen full-height menu scaling.
-- Only changes the final screen composite; menu logic and input stay native.
return function(mod)
  local okStack, Stack = pcall(require, "src.ui.game3.stack")
  local lastStandaloneDraw = -math.huge

  local function markDraw()
    if love and love.timer and love.timer.getTime then
      lastStandaloneDraw = love.timer.getTime()
    end
  end

  -- Boot menus are not on the normal in-game menu stack: title screen,
  -- Continue/New Game/save selection, Mystery Gift, and Oak's opening.
  local okBoot, Boot = pcall(require, "src.ui.game3.boot")
  if okBoot and Boot and type(Boot.draw) == "function" then
    local originalDraw = Boot.draw
    Boot.draw = function(state, ...)
      local result = originalDraw(state, ...)
      if state and state.phase then markDraw() end
      return result
    end
  end

  -- FRLG's "Previously on your quest" playback is also outside the stack.
  local okQuest, QuestLog = pcall(require, "src.ui.game3.quest_log")
  if okQuest and QuestLog and type(QuestLog.draw) == "function" then
    local originalDraw = QuestLog.draw
    QuestLog.draw = function(...)
      local result = originalDraw(...)
      markDraw()
      return result
    end
  end

  if not (mod.hooks and mod.hooks.wrap) then return end
  mod.hooks:wrap("render.compose", function(next, renderer, ctx)
    if not (ctx and ctx.uiCanvas and love and love.graphics) then
      return next(renderer, ctx)
    end

    local top = okStack and Stack and Stack.top and Stack.top()
    -- Only scale menus that replace the whole playfield. The Start/pause
    -- menu and Save dialog are overlays and must retain the overworld below.
    local overlayMenus = { start = true, start_menu = true, save = true,
      save_menu = true, choice = true, yes_no = true }
    local stackMenu = top and top.isMenu == true
      and not overlayMenus[top.id]
      and (top.hideBelow ~= false)
    local standaloneMenu = false
    if love.timer and love.timer.getTime then
      -- A standalone UI draw must have happened in this render frame.
      standaloneMenu = love.timer.getTime() - lastStandaloneDraw < 0.05
    end
    if not stackMenu and not standaloneMenu then
      return next(renderer, ctx)
    end

    local ww = tonumber(ctx.ww) or love.graphics.getWidth()
    local wh = tonumber(ctx.wh) or love.graphics.getHeight()
    local cw, ch = ctx.uiCanvas:getDimensions()
    if ww <= 0 or wh <= 0 or cw <= 0 or ch <= 0 then
      return next(renderer, ctx)
    end

    -- Visible Gen 3 screen is 240x160. The renderer may allocate a larger
    -- backing canvas; crop to the actual menu instead of scaling the padding.
    local menuW, menuH = math.min(240, cw), math.min(160, ch)
    local scale = math.min(ww / menuW, wh / menuH)
    local dw, dh = menuW * scale, menuH * scale
    local quad = love.graphics.newQuad(0, 0, menuW, menuH, cw, ch)
    love.graphics.push("all")
    love.graphics.origin()
    love.graphics.setScissor()
    love.graphics.setShader()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.clear(0, 0, 0, 1)
    ctx.uiCanvas:setFilter("nearest", "nearest")
    love.graphics.draw(ctx.uiCanvas, quad, (ww - dw) / 2,
      (wh - dh) / 2, 0, scale, scale)
    love.graphics.pop()
    quad:release()
    return true
  end, -2500)
end
