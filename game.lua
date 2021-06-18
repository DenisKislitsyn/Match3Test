local board_m = require("board_state")
local check_m = require("check_module")

-- Game Functions
function dump()
    local output_str = "   -------------------"
    for y = board_m.props.HEIGHT, 1, -1 do
        output_str = output_str .. "\n" .. (y-1) .. '| '
        for x = 1, board_m.props.WIDTH do
            output_str = output_str .. board_m.state[y][x] .. " "
        end
    end
    output_str = output_str .. "\n   -------------------\n   0 1 2 3 4 5 6 7 8 9"
    print(output_str)
end

function mix()
    print("[DEBUG LOG] No more possible moves - do mix")
    local function shuffle( list )
        local res = {}
        for i = #list, 1, -1 do
            local j = math.random(i)
            list[i], list[j] = list[j], list[i]
            table.insert(res, list[i])
        end
        return res
    end

    for y = 1, board_m.props.HEIGHT do
        shuffle(board_m.state[y])
    end
    shuffle(board_m.state)

    tick()
end

local ticks_count = 0
function tick(is_init)
    local items_to_remove = {}
    local items_to_remove_count = 0

    check_m.check_X_rows(items_to_remove)
    check_m.check_Y_rows(items_to_remove)

    for key, value in pairs(items_to_remove) do
        board_m.remove_item(value[1], value[2])
        items_to_remove_count = items_to_remove_count + 1
    end

    if items_to_remove_count > 0 then
        ticks_count = ticks_count + 1
        board_m.remove_items(function()
            if not is_init then
                print("[DEBUG LOG] Tick #" .. ticks_count .. ". Removed items count = " .. items_to_remove_count)
                dump()
            end
            tick(is_init)
        end)
    else
        if is_init then dump() end
        ticks_count = 0

        if check_m.is_mix_needed() then
            mix()
        end
    end
end

function move(from, to)
    local item_1 = board_m.state[from.y][from.x]
    local item_2 = board_m.state[to.y][to.x]

    if check_m.is_chain_exist(from.y, from.x, item_2) == false and check_m.is_chain_exist(to.y, to.x, item_1) == false then
        print("[DEBUG LOG] Move items back because no chains")
        dump()
    else
        board_m.replace_items(
                {y = from.y, x = from.x, item = item_1},
                {y = to.y, x = to.x, item = item_2})

        tick()
    end
end

function init()
    board_m.fill_board(function()
        tick(true)
    end)
end
init()

-- User Input
local user_commands = {
    moving = {
        u = {
            action = { axis = "y", target = 1 }
        },
        d = {
            action = { axis = "y", target = -1 }
        },
        l = {
            action = { axis = "x", target = -1 }
        },
        r = {
            action = { axis = "x", target = 1 }
        }
    },
    control = {
        ["quit"] = "q",
        ["restart"] = "r"
    }
}

local function prompt_read(prompt)
    print(prompt)
    return tostring(io.read())
end

local function parse_input(str)
    local res = {}
    res["move_from_x"] = tonumber(string.sub(str, 3,4)) + 1
    res["move_from_y"] = tonumber(string.sub(str, 5,6)) + 1
    res["move_direction"] = string.sub(str, 7,8)

    return res
end

local function is_user_input_valid(str)
    if string.match(str, "m %d %d %a") then
        local command = parse_input(str)
        if board_m.state[command.move_from_y] and board_m.state[command.move_from_y][command.move_from_x] and user_commands.moving[command.move_direction] ~= nil then
            return true
        end
    end
    return false
end

repeat
    local user_input = prompt_read("\nEnter command like 'm 0-9 0-9 l/r/u/d' : ")

    if user_input == user_commands.control.restart then
        board_m.fill_board(function()
            tick(true)
        end)
    else
        if is_user_input_valid(user_input) then
            local command = parse_input(user_input)
            local action = user_commands.moving[command.move_direction].action
            local move_to_x, move_to_y

            if action.axis == "x" then
                move_to_x = command.move_from_x + action.target
                move_to_y = command.move_from_y
            elseif action.axis == "y" then
                move_to_x = command.move_from_x
                move_to_y = command.move_from_y + action.target
            end

            if check_m.is_move_possible(move_to_y, move_to_x) then
                print("[DEBUG LOG] Can't do this move!")
            else
                move({y = command.move_from_y, x = command.move_from_x}, {y = move_to_y, x = move_to_x})
            end
        else
            print("[DEBUG LOG] Invalid command!")
        end
    end
until user_input == user_commands.control.quit
