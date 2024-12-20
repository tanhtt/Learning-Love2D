local love = require "love"
local button = require "Button"
local enemy = require "Enemy"

math.randomseed(os.time())

-- Create Image

local game = {
    difficulty = 1,
    state = {
        menu = true,
        running = false,
        paused = false,
        ended = false,
        credit = false
    },
    points = 0,
    levels = {15, 30, 60, 120}
}

local fonts = {
    medium = {
        font = love.graphics.newFont(16),
        size = 16
    },
    large = {
        font = love.graphics.newFont(24),
        size = 24
    },
    massive = {
        font = love.graphics.newFont(60),
        size = 60
    }
}

local player = {
    radius = 20,
    x = 30,
    y = 30
}

local buttons = {
    menu_state = {},
    ended_state = {},
    credit_state = {}
}

local enemies = {}

local function changeGameState(state)
    game.state["menu"] = state == "menu"
    game.state["running"] = state == "running"
    game.state["paused"] = state == "paused"
    game.state["ended"] = state == "ended"
    game.state["credit"] = state == "credit"
end

local function startNewGame()
    changeGameState("running")
    game.points = 0

    enemies = {
        enemy(1)
    }
end

function love.mousepressed(x, y, button, istouch, presses)
    if not game.state["running"] then
        if button == 1 then
            if game.state["menu"] then
                for index in pairs(buttons.menu_state) do
                    buttons.menu_state[index]:checkPressed(x,y,player.radius)
                end
            elseif game.state["ended"] then
                for index in pairs(buttons.ended_state) do
                    buttons.ended_state[index]:checkPressed(x,y,player.radius)
                end
            elseif game.state["credit"] then
                for index in pairs(buttons.credit_state) do
                    buttons.credit_state[index]:checkPressed(x,y,player.radius)
                end
            end
        end
    end
end

function love.load()
    love.mouse.setVisible(false)
    love.window.setTitle("Save the ball!")

    _G.avatar = love.graphics.newImage("sprites/white.png")

    buttons.menu_state.play_game = button("Play Game",startNewGame, nil, 120, 40)
    buttons.menu_state.credit = button("Credits", changeGameState, "credit", 120, 40)
    buttons.menu_state.exit_game = button("Exit", love.event.quit, nil, 120, 40)

    buttons.ended_state.replay_game = button("Replay", startNewGame, nil, 100, 50)
    buttons.ended_state.menu = button("Menu", changeGameState, "menu", 100, 50)
    buttons.ended_state.exit_game = button("Exit", love.event.quit, nil, 100, 50)

    buttons.credit_state.menu = button("Menu", changeGameState, "menu", 100, 50)
end

function love.update(dt)
    player.x, player.y = love.mouse.getPosition()

    if game.state["running"] then
        for i = 1, #enemies do
            if not enemies[i]:checkTouched(player.x, player.y, player.radius) then
                enemies[i]:move(player.x, player.y)

                for i = 1, #game.levels do
                    if math.floor(game.points) == game.levels[i] then
                        table.insert(enemies, 1, enemy(game.difficulty * (i + 1)))
                        game.points = game.points + 1
                    end
                end
            else
                changeGameState("ended")
            end
        end
        game.points = game.points + dt
    end
end

function love.draw()
    love.graphics.setFont(fonts.medium.font)

    love.graphics.printf("FPS: ".. love.timer.getFPS(), fonts.medium.font,10,  love.graphics.getHeight() - 30, love.graphics.getWidth())

    if game.state["running"] then
        love.graphics.printf(math.floor(game.points), fonts.large.font, 0, 10, love.graphics.getWidth(), "center")

        for i = 1, #enemies do
            enemies[i]:draw()
        end

        love.graphics.circle("fill", player.x, player.y, player.radius)

    elseif game.state["menu"] then
        buttons.menu_state.play_game:draw(10, 20, 17, 10)
        buttons.menu_state.credit:draw(10, 70, 17, 10)
        buttons.menu_state.exit_game:draw(10, 120, 17, 10)

    elseif game.state["ended"] then
        buttons.ended_state.replay_game:draw(love.graphics.getWidth() / 2.25, love.graphics.getHeight() / 1.8, 10, 10)
        buttons.ended_state.menu:draw(love.graphics.getWidth() / 2.25, love.graphics.getHeight() / 1.53, 17, 10)
        buttons.ended_state.exit_game:draw(love.graphics.getWidth() / 2.25, love.graphics.getHeight() / 1.33, 22, 10)

        love.graphics.printf(math.floor(game.points), fonts.massive.font, 0, love.graphics.getHeight() /2 - fonts.massive.size, love.graphics.getWidth(), "center")
        
    elseif game.state["credit"] then
        buttons.credit_state.menu:draw(love.graphics.getWidth() - 200, love.graphics.getHeight() -100, 17, 10)
        love.graphics.draw(avatar,100, 100, 0, 100)
        love.graphics.printf("Made by Edd! Just following tutorial :)) <3", 
            love.graphics.getWidth() * 1/3,  -- Tọa độ x
            love.graphics.getHeight() * 2/3, -- Tọa độ y
            love.graphics.getWidth() / 3,    -- Chiều rộng vùng văn bản
            "center"                         -- Căn giữa
        )
    end

    if not game.state["running"] then
        love.graphics.circle("fill", player.x, player.y, player.radius / 2)
    end
end