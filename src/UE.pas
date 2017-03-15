unit UE;      //E = Exit/Entrance

interface

uses
  w3system;

type
  TE = class(TObject)
    X, Y : integer;
    Won : boolean;
    constructor create(newX, newY : integer);
    //Checks if the player is over the door, so it has won
    function isDone(Cord1, Cord3, Cord4 : float) : boolean;
  end;

const
  HEIGHT = 60;
  WIDTH = 30;

implementation

constructor TE.create(newX, newY : integer);
begin
  X := newX;
  Y := newY;
end;

function TE.isDone(cord1, cord3, cord4 : float) : boolean;
begin
  if (cord1 <= X + WIDTH) and (cord3 >= X) and (cord4 = Y + HEIGHT) then
    begin
      Exit(true);
    end
  else
    begin
      Exit(false);
    end;
end;

end.