unit UGameText;

interface

uses
  w3system;

type
  TText = class(TObject)
    text, colour : string;
    x, y : integer;
    constructor create(newText, newColour : string; newX, newY : integer);
  end;

implementation

constructor TText.create(newText, newColour : string; newX, newY : integer);
begin
  text := newText;
  x := newX;
  y := newY;
  colour := newColour;
end;

end.