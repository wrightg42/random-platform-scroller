unit UAi;

interface

uses
  w3system, UPlayer, UBullet, UPlat, UGlobalsNoUserTypes;

type TAi = class(UPlayer.TPlayer)
  OnPlat, OnRand : boolean;
  PlatID : integer;
  LOSXMin, LOSXMax, LOSYMin, LOSYMax : float; //LOS = Line Of Shot
  PX, PY : float; //P = Player
  TargRunBefore : boolean;
  TargRand1 : boolean;
  TargID1 : integer;
  procedure WorkOutMoves(player : UPlayer.TPlayer; Bullets : array of TBullet; FixedPlats, RandPlats : Array of TPlat; screenwidth, screenheight : integer);
  procedure WorkOutJumpTargs(TargNO : integer; FixedPlats, RandPlats : array of TPlat; X, Y : float);
  function CanJumpTo(FixedPlats, RandPlats : array of TPlat; X, Y : float; TargetID : integer; isTargetRand : boolean = true) : boolean;
  procedure PlayerInfo(player : TPlayer; FixedPlats, RandPlats : Array of TPlat; screenwidth : integer);
  function SimulateBullet(FixedPlats, RandPlats : array of TPlat; testLeft : boolean) : float;
  procedure OnPlatform(FixedPlats, RandPlats : Array of TPlat);
  procedure OnPlatform(FixedPlats, RandPlats : Array of TPlat; x, y : float); overload;
  procedure Shoot(Bullets : array of TBullet);
  procedure MoveOnPlat(targPlats, playerPlats : array of TPlat);
  procedure MoveInAir(targPlats : array of TPlat);
end;

implementation
var
LastX, LastY : float;
counter : integer;

procedure TAi.WorkOutMoves(player : UPlayer.TPlayer; Bullets : array of TBullet; FixedPlats, RandPlats : Array of TPlat; screenwidth, screenheight : integer);
begin
  //Move Left or right or down and jump starter
  if OnPlat then
    begin
      if (Y - PY < 10) or (Y - PY > -10) then
        begin
          if (X > PX) then
            Move(MoveCommands.left)
          else
            Move(MoveCommands.right);
        end
      else if TargRand1 then
        begin
		      if OnRand then
            MoveOnPlat(RandPlats, RandPlats)
		      else
		        MoveOnPlat(RandPlats, FixedPlats);
		    end
      else
	      begin
    		  if OnRand then
		        MoveOnPlat(FixedPlats, RandPlats)
	        else
	  	      MoveOnPlat(FixedPlats, FixedPlats);
		    end;
    end
  else if OnPlat = false then
    begin
      if TargRand1 then
        MoveInAir(RandPlats)
      else
        MoveInAir(FixedPlats);
    end;

  //Update meathods
  PlayerInfo(player, FixedPlats, RandPlats, screenwidth);
  OnPlatform(FixedPlats, RandPlats);
  if ((TargID1 = PlatID) and (TargRand1 = OnRand)) or (TargRunBefore = false) then
    begin
      WorkOutJumpTargs(1, FixedPlats, RandPlats, X, Y);
      TargRunBefore := true;
    end;

  update(maxX + ScreenWidth, AIHEALTH);
  isGrounded(maxY + ScreenHeight, FixedPlats, RandPlats);

  updateShoot();

  shoot(Bullets);

  if (LastX = X) and (counter = 4) then
    doJump();
  if counter = 4 then
    counter := 0
  else
    inc(counter);
  LastX := X;
end;

procedure TAi.WorkOutJumpTargs(TargNO : integer; FixedPlats, RandPlats : array of TPlat; X, Y : float);
begin
  For var i := 0 to High(RandPlats) do
   begin
      if PY >= Y then
        begin
          if PX > X then
                  begin
                      if (CanJumpTo(FixedPlats, RandPlats, X, Y, i, true)) and ((RandPlats[i].X > X + PLAYERHEAD) or (RandPlats[i].X + RandPlats[i].Width > X + PLAYERHEAD)) and (RandPlats[i].Y + 200 >= Y) then
                         begin
                            TargID1 := i;
                            TargRand1 := true;
                            exit;
                         end;
                  end
               else
                  begin
                      if (CanJumpTo(FixedPlats, RandPlats, X, Y, i, true)) and ((RandPlats[i].X < X) or (RandPlats[i].X + RandPlats[i].WIDTH < X)) and (RandPlats[i].Y + 200 >= Y) then
                         begin
                            TargID1 := i;
                            TargRand1 := true;
                            exit;
                         end;
                  end;
            end
         else
            begin
               if PX > X then
                  begin
                      if (CanJumpTo(FixedPlats, RandPlats, X, Y, i, true)) and ((RandPlats[i].X > X + PLAYERHEAD) or (RandPlats[i].X + RandPlats[i].Width > X + PLAYERHEAD)) and (RandPlats[i].Y - 200 <= Y) then
                         begin
                            TargID1 := i;
                            TargRand1 := true;
                            exit;
                         end;
                  end
               else
                  begin
                      if (CanJumpTo(FixedPlats, RandPlats, X, Y, i, true)) and ((RandPlats[i].X < X) or (RandPlats[i].X  + RandPlats[i].WIDTH < X)) and (RandPlats[i].Y - 200 <= Y) then
                         begin
                            TargID1 := i;
                            TargRand1 := true;
                            exit;
                         end;
                  end;
            end;
      end;

   For var i := 0 to High(FixedPlats) do
      begin
         if PY >= Y then
            begin
               if PX > X then
                  begin
                      if (CanJumpTo(FixedPlats, RandPlats, X, Y, i, false)) and ((FixedPlats[i].X > X + PLAYERHEAD) or (FixedPlats[i].X + FixedPlats[i].Width > X + PLAYERHEAD)) and (FixedPlats[i].Y + 200 >= Y + PLAYERHEIGHT) then
                         begin
                            TargID1 := i;
                            TargRand1 := false;
                            exit;
                         end;
                  end
               else
                  begin
                      if (CanJumpTo(FixedPlats, RandPlats, X, Y, i, false)) and ((FixedPlats[i].X < X) or (FixedPlats[i].X  + FixedPlats[i].WIDTH < X)) and (FixedPlats[i].Y + 200 >= Y + PLAYERHEIGHT) then
                         begin
                            TargID1 := i;
                            TargRand1 := false;
                            exit;
                         end;
                  end;
            end
         else
            begin
               if PX > X then
                  begin
                      if (CanJumpTo(FixedPlats, RandPlats, X, Y, i, false)) and ((FixedPlats[i].X > X + PLAYERHEAD) or (FixedPlats[i].X + FixedPlats[i].Width > X + PLAYERHEAD)) and (FixedPlats[i].Y - 200 <= Y) then
                         begin
                            TargID1 := i;
                            TargRand1 := false;
                            exit;
                         end;
                  end
               else
                  begin
                      if (CanJumpTo(FixedPlats, RandPlats, X, Y, i, false)) and ((FixedPlats[i].X < X) or (FixedPlats[i].X  + FixedPlats[i].WIDTH < X)) and (FixedPlats[i].Y  - 200 <= Y) then
                         begin
                            TargID1 := i;
                            TargRand1 := false;
                            exit;
                         end;
                  end;
            end;
      end;
end;

function TAi.CanJumpTo(FixedPlats, RandPlats : array of TPlat; X, Y : float; TargetID : integer; isTargetRand : boolean = true) : boolean;
var
lastX : float;
testAi : TAi;
counter : integer;
begin
  //Start AI
  testAi := TAi.start();
  testAi.create(X, Y, Colour, 1, FixedPlats, RandPlats);
  testAi.isGrounded(maxY, FixedPlats, RandPlats);
  testAi.update(maxX, 1);
  testAi.Move(MoveCommands.null);
  testAi.OnPlatform(FixedPlats, Randplats);
  testAi.TargID1 := TargetID;
  testAi.TargRand1 := isTargetRand;

  //Move it to the edge of Platform
  if (testAi.OnPlat) then
    begin
      repeat
  	    if isTargetRand then
	  	    begin
			      if testAi.OnRand then
				      MoveOnPlat(RandPlats, RandPlats)
				    else
				      MoveOnPlat(RandPlats, FixedPlats);
			     end
			  else
			    begin
			      if testAi.OnRand then
				      MoveOnPlat(FixedPlats, RandPlats)
				    else
				      MoveOnPlat(FixedPlats, FixedPlats);
			    end;

			  testAi.update(maxX, 1);
			  testAi.isGrounded(maxY, FixedPlats, RandPlats);

        if (LastX = testAi.X) and (counter = 4) then
          testAi.doJump();
        if counter = 4 then
          counter := 0
        else
          inc(counter);
        LastX := testAi.X;

		  until (testAi.AtGround = false) or (Fall <> -1);
	  end;

  //Simulate Jump
  repeat
    begin
      if isTargetRand then
  	    testAi.MoveInAir(RandPlats)
 		  else
		    testAi.MoveInAir(FixedPlats);

        testAi.update(maxX, 1);
        testAi.isGrounded(maxY, FixedPlats, RandPlats);
    end;
  until (testAi.AtGround) or (testAi.Y > maxY);

  //Evaluate if its on the correct platform
  testAi.OnPlatform(FixedPlats, Randplats);
  if (testAi.PlatID = TargetID) and (testAi.OnRand = istargetRand) then
    Exit(true)
  else
    Exit(false);
end;

procedure TAi.PlayerInfo(player : TPlayer; FixedPlats, RandPlats : Array of TPlat; screenwidth : integer);
begin
  LOSYMin := player.Y - 5;
  LOSYMax := player.Y + PLAYERHEIGHT + 5;
  PX := player.X;
  PY := player.Y;
  LOSXMin := SimulateBullet(FixedPlats, RandPlats, true);
  LOSXMax := SimulateBullet(FixedPlats, RandPlats, false);
end;

function TAi.SimulateBullet(FixedPlats, RandPlats : array of TPlat; testLeft : boolean) : float;
var
angle : integer;
hit : boolean;
begin
  hit := false;
  if testLeft then
    angle := 270
  else
    angle := 90;

  var Bullet := TBullet.Create(testLeft, PX, (LOSYMax - LOSYMin) + LOSYMin - (UBullet.WIDTH / 2), 1, angle);

  repeat
    Bullet.Move();

	  for var i := 0 to High(FixedPlats) do
      begin
  	    if Bullet.HitPlat(FixedPlats[i]) then
			    hit := true;
		  end;

	  for var i := 0 to High(RandPlats) do
	    begin
		    if Bullet.HitPlat(RandPlats[i]) then
			    hit := true;
      end;
  until (hit = True) or ((testLeft) and (Bullet.X <= 0)) or ((testLeft = false) and (Bullet.X >= maxX));

  if (testLeft) then
    exit(Bullet.X)
  else
    exit(Bullet.X + UBullet.WIDTH);
end;

procedure TAi.OnPlatform(FixedPlats, RandPlats : Array of TPlat);
begin
  OnPlatform(FixedPlats, RandPlats, X, Y);
end;

procedure TAi.OnPlatform(FixedPlats, RandPlats : Array of TPlat; x, y : float);
begin
  for var i := 0 to High(RandPlats) do
    begin
      if (x <= RandPlats[i].X + RandPlats[i].Width) and (x + PLAYERHEAD >= RandPlats[i].X) and (y + PLAYERHEAD = RandPlats[i].Y) then
        begin
          OnPlat := True;
          OnRand := True;
          PlatID := i;
          Exit;
        end;
    end;

  for var i := 0 to High(FixedPlats) do
    begin
      if (x <= FixedPlats[i].X + FixedPlats[i].Width) and (x + PLAYERHEAD >= FixedPlats[i].X) and (y + PLAYERHEAD = FixedPlats[i].Y) then
        begin
          OnPlat := True;
          OnRand := False;
          PlatID := i;
          Exit;
        end;
    end;

  OnPlat := False;
  OnRand := False;
  PlatID := 0;
end;

procedure TAi.shoot(Bullets : array of TBullet);
begin
  if (Y > LOSYMin - 30) and (Y + PLAYERHEIGHT < LOSYMax + 50) and (X > LOSXMin) and (X + PLAYERHEAD < LOSXMax) then
    begin
      if (canShoot = True) then
        begin
          i := -1;
          repeat
            i += 1;
          until (Bullets[i].Shot = False) or (i = High(Bullets));
          if i = High(Bullets) then
            begin
              i += 1;
            end;
          if FaceLeft = True then
            begin
              Bullets[i] := UBullet.TBullet.create(FaceLeft, X - UBullet.WIDTH - 1, Y + UPlayer.PLAYERHEAD + 3, Damage, 270);
            end
          else
            begin
              Bullets[i] := UBullet.TBullet.create(FaceLeft, X + UPlayer.PLAYERHEAD + 1, Y + UPlayer.PLAYERHEAD + 3, Damage, 90);
            end;
         resetShoot();
        end;
    end;
end;

procedure TAi.MoveOnPlat(targPlats, playerPlats : array of TPlat);
begin
  if (targPlats[TargID1].X > X + PLAYERHEAD) and (targPlats[TargID1].X + targPlats[TargID1].Width > X) and (targPlats[TargID1].Y > Y) then
    begin
		  doFall();
	  end
  else if (X > targPlats[TargID1].X + targPlats[TargID1].Width) then
	  begin
	 	  Move(MoveCommands.left);
        if (X < playerPlats[PlatID].X) then
		      begin
			      doJump();
			      Y -= 1;
	        end;
	  end
  else if (X + PLAYERHEAD < targPlats[TargID1].X) then
	  begin
		  Move(MoveCommands.right);
	    if (X + PLAYERHEAD > playerPlats[PlatID].X + playerPlats[PlatID].Width) then
		    begin
		 	    doJump();
    	    Y -= 1;
		    end;
	  end;
end;

procedure TAi.MoveInAir(targPlats : array of TPlat);
begin
  if (X + PLAYERHEAD >= targPlats[TargID1].X) and (X <= targPlats[TargID1].X + targPlats[TargID1].Width) then
	  begin
 		  Move(MoveCommands.null);
	  end
  else
	  begin
		  if (X + PLAYERHEAD < targPlats[TargID1].X) then
		    begin
			    Move(MoveCommands.right);
	      end
      else if (X > targPlats[TargID1].X) then
	      begin
		      Move(MoveCommands.left);
	      end;

      if (Y > targPlats[TargID1].Y) then
	      begin
	        doJump();
		      Y -= 1;
        end;
    end;
end;

end.