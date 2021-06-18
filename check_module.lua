local board_state = require("board_state")

local M = {}

local function is_any_move_exist(y, x)
    local item = board_state.state[y][x]

    if board_state.state[y-1] ~= nil then
        if board_state.state[y-1][x+1] == item and board_state.state[y-1][x-1] == item then return true end
        if board_state.state[y-1][x-1] == item and board_state.state[y-1][x-2] == item then return true end
        if board_state.state[y-1][x+1] == item and board_state.state[y-1][x+2] == item then return true end

        if board_state.state[y+1] ~= nil then
            if board_state.state[y-1][x-1] == item and board_state.state[y+1][x-1] == item then return true end
            if board_state.state[y-1][x+1] == item and board_state.state[y+1][x+1] == item then return true end
        end

        if board_state.state[y-2] ~= nil then
            if board_state.state[y-1][x-1] == item and board_state.state[y-2][x-1] == item then return true end
            if board_state.state[y-1][x+1] == item and board_state.state[y-2][x+1] == item then return true end
            if board_state.state[y-3] ~= nil then
                if board_state.state[y-2][x] == item and board_state.state[y-3][x] == item then return true end
            end
        end
    elseif board_state.state[y+1] ~= nil then
        if board_state.state[y+1][x-1] == item and board_state.state[y+1][x+1] == item then return true end
        if board_state.state[y+1][x-1] == item and board_state.state[y+1][x-2] == item then return true end
        if board_state.state[y+1][x+1] == item and board_state.state[y+1][x+2] == item then return true end

        if board_state.state[y+2] ~= nil then
            if board_state.state[y+1][x-1] == item and board_state.state[y+2][x-1] == item then return true end
            if board_state.state[y+1][x+1] == item and board_state.state[y+2][x+1] == item then return true end
            if board_state.state[y+3] ~= nil then
                if board_state.state[y+2][x] == item and board_state.state[y+3][x] == item then return true end
            end
        end
    end
    if board_state.state[y][x-2] == item and board_state.state[y][x-3] == item then return true end
    if board_state.state[y][x+2] == item and board_state.state[y][x+3] == item then return true end

    return false
end

function M.check_X_rows(items_to_remove)
    for y = 1, board_state.props.HEIGHT do
        local similar_items_X = {}
        for x = 2, board_state.props.WIDTH do
            if board_state.state[y][x] == board_state.state[y][x-1] then
                if #similar_items_X == 0 then
                    table.insert(similar_items_X, {key = y .. x-1, value = {y, x-1}})
                end
                table.insert(similar_items_X, {key = y .. x, value = {y, x}})
            elseif #similar_items_X > 0 then
                if #similar_items_X >= board_state.combinations.EASY then
                    for i =1, #similar_items_X do
                        if items_to_remove[similar_items_X[i].key] == nil then
                            items_to_remove[similar_items_X[i].key] = similar_items_X[i].value
                        end
                    end
                end
                similar_items_X = {}
            end
        end
    end

    return items_to_remove
end

function M.check_Y_rows(items_to_remove)
    for x = 1, board_state.props.WIDTH do
        local similar_items_Y = {}
        for y = 2, board_state.props.HEIGHT do
            if board_state.state[y][x] == board_state.state[y-1][x] then
                if #similar_items_Y == 0 then
                    table.insert(similar_items_Y, {key = y-1 .. x, value = {y-1, x}})
                end
                table.insert(similar_items_Y, {key = y .. x, value = {y, x}})
            elseif #similar_items_Y > 0 then
                if #similar_items_Y >= board_state.combinations.EASY then
                    for i =1, #similar_items_Y do
                        if items_to_remove[similar_items_Y[i].key] == nil then
                            items_to_remove[similar_items_Y[i].key] = similar_items_Y[i].value
                        end
                    end
                end
                similar_items_Y = {}
            end
        end
    end
end

function M.is_chain_exist(y, x, item)
    if (board_state.state[y][x-1] == item and board_state.state[y][x+1] == item) or
            (board_state.state[y][x-1] == item and board_state.state[y][x-2] == item) or
            (board_state.state[y][x+1] == item and board_state.state[y][x+2] == item) then
        return true
    end
    if (board_state.state[y-1] and board_state.state[y-2] and board_state.state[y-1][x] == item and board_state.state[y-2][x] == item) or
            (board_state.state[y+1] and board_state.state[y+2] and board_state.state[y+1][x] == item and board_state.state[y+2][x] == item) or
            (board_state.state[y-1] and board_state.state[y+1] and board_state.state[y-1][x] == item and board_state.state[y+1][x] == item) then
        return true
    end

    return false
end

function M.is_mix_needed()
    local is_mix_needed = true
    for y = 1, board_state.props.HEIGHT do
        if is_mix_needed == false then break end
        for x = 1, board_state.props.WIDTH do
            if is_any_move_exist(y, x) then
                is_mix_needed = false
                break
            end
        end
    end

    return is_mix_needed
end

function M.is_move_possible(y, x)
    return (board_state.state[y] == nil or board_state.state[y][x] == nil)
end

return M