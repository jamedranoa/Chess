# encoding: utf-8
require "./board"
class Piece
  attr_reader :color
  attr_accessor :position
  def initialize(color,position,board)
    @board = board
    @position = position
    @color = color
    @board[position] = self
  end
  
  # work in progress
  def dup(new_board)
    self.class.new(self.color,self.position,new_board)
  end
  
  def moves
    raise UnimplementedError
  end
  
  def valid_moves
    self.moves.select {|move| !move_into_check?(move) }
  end
  
  def move_into_check?(pos)
    new_board = @board.dup
    new_board.move!(self.position, pos)
    new_board.in_check?(self.color)
  end
  
  def in_board?(position)
    position.all? {|coord| (coord >= 0) && (coord < 8) }
  end 
  
  def has_ally?(pos)
    !@board[pos].nil? && @board[pos].color == self.color
  end
  
  def has_opponent?(pos)
    !@board[pos].nil? && @board[pos].color != self.color
  end
  
  
end

class SlidingPiece < Piece
  def moves
    directions = move_dirs
    
    possible_moves = []
    directions.each do |direction|
      possible_moves += generate_positions(direction)
    end
    possible_moves
  end
  
  def generate_positions(direction)
    a, b = direction[0],direction[1]
    x, y = @position.first + a, @position.last + b
    
    positions = []
    while in_board?([x,y])
      new_position = [x,y]
      square = @board[new_position]
      
      break if has_ally?(new_position)
      
      positions << new_position
      
      break unless square.nil?
      
      x, y = x+a, y+b
    end
    
    positions
  end
end

class SteppingPiece < Piece
  
  def moves
    directions = move_dirs
    
    possible_moves = []
    directions.each do |a,b| 
      new_position = [@position[0] + a, @position[1] + b]
      possible_moves << new_position if valid_pos?(new_position)
    end
    
    possible_moves
  end
  
  def valid_pos?(pos)
    in_board?(pos) && (has_opponent?(pos) || @board[pos].nil?)
  end
  
end

class Bishop < SlidingPiece
 
  def move_dirs
    [[1,1], [-1,-1], [1,-1], [-1,1]]
  end
  
  def to_s
    (color == :w) ? "♗" : "♝"
  end
  
end

class Rook < SlidingPiece
  
  def move_dirs
    [[0,1], [-1,0], [1,0], [0,-1]]
  end
  
  def to_s
    (color == :w) ? "♖" : "♜"
  end
end


class Queen < SlidingPiece
  
  def move_dirs
    [[1,1], [-1,-1], [1,-1], [-1,1],
    [0,1], [-1,0], [1,0], [0,-1]]
  end
  
  def to_s
     (color == :w) ? "♕" : "♛"
  end
  
end

class Knight < SteppingPiece
  
  def move_dirs
    [[ 2, 1], [ 2, -1],
     [-2, 1], [-2, -1],
     [ 1, 2], [ 1, -2],
     [-1, 2], [-1, -2]]
  end
  
  def to_s
    (color == :w) ? "♘" : "♞"
  end
  
end

class King < SteppingPiece
  
  def move_dirs
    [[1,1], [-1,-1], [1,-1], [-1,1],
    [0,1], [-1,0], [1,0], [0,-1]]
  end
  
  def to_s
    (color == :w) ? "♔" : "♚"
  end
  
end

class Pawn < Piece
  
  def moves
    forward_directions,side_directions = move_dirs
    possible_moves =[]
    
    side_directions.each do |a,b|
      new_position = [@position[0] + a, @position[1] + b]
      possible_moves << new_position if valid_side_pos?(new_position)
    end 
    
    forward_directions.each do |a,b|
      new_position = [@position[0] + a, @position[1] + b]
      break unless @board[new_position].nil? #stops jumping piece on first move
      possible_moves << new_position
    end 
    possible_moves
  end
  
  def valid_side_pos?(pos)
    in_board?(pos) && has_opponent?(pos)
  end
  
  def move_dirs
    sym = self.color == :w ? -1 : 1  
    forward_directions = [[(sym * 1),0]]
    forward_directions << [(sym * 2),0] if first_move?
    side_directions  = [[(sym * 1),1],[(sym * 1),-1]]
    [forward_directions,side_directions]
  end  
  
  def first_move?
    (self.color == :w && self.position[0] == 6) ||
    (self.color == :b && self.position[0] == 1)
  end
  
  def to_s
    (color == :w) ? "♙" : "♟"
  end
      
  
end



if __FILE__ == $PROGRAM_NAME
  b = Board.new
  p1 = Pawn.new(:w,[1,1],b)
  #p2 = Pawn.new(:w,[1,1],b)
  #b[[2,2]] = p1
  #b[[1,1]] = p2 
  p p1.moves
  
  
end
