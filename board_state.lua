-- Const
local M = {}
M.props = {
    WIDTH = 10,
    HEIGHT = 10,
    colors = {"A", "B", "C", "D", "E", "F"}
}
M.combinations = {
    EASY = 3,
    MEDIUM = 4,
    HARD = 5
}
M.state = {}

function M.fill_board(cb)
    M.state = {}
    math.randomseed(os.time())
    for y = 1, M.props.HEIGHT do
        M.state[y] = {}
        for x = 1, M.props.WIDTH do
            local rand_color = M.props.colors[math.random(#M.props.colors)]
            M.state[y][x] = rand_color
        end
    end

    if cb then cb() end
end

function M.remove_items(cb)
    for y = 1, M.props.HEIGHT do
        for x = 1, M.props.WIDTH do
            if M.state[y][x] == nil then
                local step = 1
                local is_item_replaced

                while y+step <= M.props.HEIGHT do
                    if M.state[y+step][x] ~= nil then
                        M.state[y][x] = M.state[y+step][x]
                        M.state[y+step][x] = nil
                        is_item_replaced = true
                        break
                    else
                        step = step + 1
                    end
                end

                if not is_item_replaced then
                    M.state[y][x] = M.props.colors[math.random(#M.props.colors)]
                end
            end
        end
    end

    if cb then cb() end
end

function M.remove_item(y, x)
    M.state[y][x] = nil
end

function M.replace_items(item_1, item_2)
    M.state[item_1.y][item_1.x] = item_2.item
    M.state[item_2.y][item_2.x] = item_1.item
end

return M