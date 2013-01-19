local states = states;

return {
	games = {
		{1, "tetris"};
		{2, "snake"};
        {3, "pacman (nope)"};
        {4, "galaga (nope)"};
        {10, "quit"};
	},
    load = {
        function()
            states:Pop("menu.main");
            states:Push("tetris.main");
        end,
        function()
            states:Pop("menu.main");
            states:Push("snake.main");
        end,
        function()
            states:Push("objects.MessageBox", "This game has not been implemented yet.");
        end,
        function()
            states:Push("objects.MessageBox", "This game has not been implemented yet.");
        end,
        function()
            os.exit();
        end
    },
};