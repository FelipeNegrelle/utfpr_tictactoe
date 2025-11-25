# UTFPR Tic-Tac-Toe with Revenge Rules

### A Unique Variation of Tic-Tac-Toe

This is an implementation of a 3-player Tic-Tac-Toe game with special "revenge" mechanics, developed as part of coursework at UTFPR.

## Game Features

* **3 players** taking turns using symbols **x**, **o**, and **+**
* **4×4 board** instead of the traditional 3×3
* **Steal mechanism**: Players can place their symbol on top of another player's symbol to "steal" that position
* **Anti-revenge rule**: If player A steals from player B, then player B cannot immediately steal back from player A on their next turn
* **Win condition**: Get 4 symbols in a row (horizontal, vertical, or diagonal)

## Architecture

The project is structured with clear separation of responsibilities:

- **`Board`**: Handles board display and basic piece placement
- **`Game`**: Manages game state, turn logic, and move validation
- **`Player`**: Represents players and handles player creation
- **`Rule`**: Contains all game rules including win conditions and steal validation

## How to Run

### Interactive Game
```bash
# Clone the repository
git clone <repository-url>
cd utfpr_tictactoe

# Compile and run the interactive game
mix compile
mix run -e "Game.main([])"
```

### Demo Mode
```bash
# Run the automated demonstration
elixir demo.exs
```

### Tests
```bash
# Run all tests
mix test
```

## How to Play

1. When you start the game, each player will choose their symbol (x, o, or +)
2. The symbols must be different for each player
3. The game displays a 4×4 board with coordinates from (1,1) to (4,4)
4. Players take turns placing their symbols
5. To make a move, enter coordinates in format (row,column) - e.g., (1,1) or (2,3)

### Game Rules

- **Empty Cell**: You can always place your symbol on an empty cell
- **Own Symbol**: You can place your symbol on a cell that already contains your symbol (reinforcement)
- **Stealing**: You can place your symbol on an opponent's symbol to "steal" that position
- **Revenge Prevention**: You cannot immediately steal back from a player who just stole from you
- **Win Condition**: First to get 4 symbols in a row (horizontal, vertical, or diagonal) wins
- **Draw**: Game ends in a draw if the board is full with no winner

### Development

### Examples

#### Revenge not allowed - example 1

1. **X plays on (1,1)** — X on empty cell — valid move  
2. **O plays on (1,1)** — O overwrites X — valid move  
3. **+ plays on (1,1)** — + overwrites O — valid move  
4. **X plays on (1,1)** — X overwrites + — valid move  
5. **O plays on (1,1)** — O overwrites X — valid move  
6. **+ plays on (2,2)** — + on empty cell — valid move  
7. **X plays on (1,1)** — invalid move: X is retaliating against O’s overwrite in move 5, violating the anti-revenge rule


#### Revenge not allowed - example 2 - revenge on a different position 

1. **X plays on (1,1)** — X on empty cell — valid move  
2. **O plays on (1,1)** — O overwrites X — valid move  
3. **+ plays on (3,3)** — + on empty cell — valid move  
4. **X plays on (2,2)** — X on empty cell — valid move  
5. **O plays on (2,2)** — O overwrites X — valid move
6. **+ plays on (2,2)** — + overwrites O — valid move  
1. **X plays on (1,1)** — invalid move: X is retaliating against O’s overwrite in move 5, violating the anti-revenge rule

## Game End Conditions

### Victory
A player wins by getting 4 symbols in a row in any of these patterns:
- **Horizontal**: Any complete row (1-4, 5-8, 9-12, or 13-16)
- **Vertical**: Any complete column (1,5,9,13 or 2,6,10,14 or 3,7,11,15 or 4,8,12,16)
- **Diagonal**: Main diagonal (1,6,11,16) or anti-diagonal (4,7,10,13)

### Draw
The game ends in a draw when the board is completely filled and no player has achieved 4 in a row.

## Technical Implementation

This implementation uses a modern Elixir architecture with:
- Pattern matching for game state management
- Struct-based data modeling
- Functional programming principles
- Comprehensive test coverage
- Clear separation of concerns between modules

### Module Responsibilities
- **Board**: Display and basic piece placement only
- **Game**: Complete game state management and business logic
- **Player**: Simple player representation
- **Rule**: All game rules and win condition checking 