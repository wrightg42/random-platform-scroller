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
  function CanJumpTo(FixedPlats, RandPlats : array of TPlat; X, Y : float; TargetID : integer; istargetRand : boolean = true) : boolean;
  procedure PlayerInfo(player : TPlayer; FixedPlats, RandPlats : Array of TPlat; screenwidth : integer);
  Procedure OnPlatform(FixedPlats, RandPlats : Array of TPlat);
  procedure OnPlatform(FixedPlats, RandPlats : Array of TPlat; x, y : float); overload;
end;

implementation
var
LastX, LastY : float;
counter : integer;

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

Procedure TAi.OnPlatform(FixedPlats, RandPlats : Array of TPlat);
begin
  OnPlatform(FixedPlats, RandPlats, X, Y);
end;


Procedure TAi.OnPlatform(FixedPlats, RandPlats : Array of TPlat; x, y : float);
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


procedure TAi.PlayerInfo(player : TPlayer; FixedPlats, RandPlats : Array of TPlat; screenwidth : integer);
var
c1, c2, c3, c4, help : float;
hit : boolean;
begin
   LOSYMin := player.Y;
   LOSYMax := player.Y + PLAYERHEIGHT;
   PX := player.X;
   PY := player.Y;

   c1 := player.X;
   c2 := LOSYMin;
   c3 := player.X + UBullet.WIDTH;
   c4 := LOSYMin + UBullet.HEIGHT;
   hit := false;
   help := -1;

   repeat
   begin
      c1 -= UBullet.WIDTH;
      c3 -= UBullet.WIDTH;

      for var i := 0 to High(FixedPlats) do
      begin
         if (c2 <= FixedPlats[i].Y + FixedPlats[i].HEIGHT) and (c4 >= FixedPlats[i].Y) and (c1 <= FixedPlats[i].X + FixedPlats[i].WIDTH) and (c3 >= FixedPlats[i].X) then
         begin
            hit := true;
         end;
      end;
      for var i := 0 to High(RandPlats) do
      begin
         if (c2 <= RandPlats[i].Y + RandPlats[i].HEIGHT) and (c4 >= RandPlats[i].Y) and (c1 <= RandPlats[i].X + RandPlats[i].WIDTH) and (c3 >= RandPlats[i].X) then
         begin
            hit := true;
         end;
      end;
      if hit = false then
      begin
         help := c3;
      end;
   end;
   until (hit = True) or (c1 <= 0);

   LOSXMin := help;
   help := -1;

   c1 := player.X;
   c2 := LOSYMin;
   c3 := player.X + UBullet.WIDTH;
   c4 := LOSYMin + UBullet.HEIGHT;
   hit := false;
   repeat
   begin
      c1 += UBullet.WIDTH;
      c3 += UBullet.WIDTH;

      for var i := 0 to High(FixedPlats) do
      begin
         if (c2 <= FixedPlats[i].Y + FixedPlats[i].HEIGHT) and (c4 >= FixedPlats[i].Y) and (c1 <= FixedPlats[i].X + FixedPlats[i].WIDTH) and (c3 >= FixedPlats[i].X) then
         begin
            hit := true;
         end;
      end;
      for var i := 0 to High(RandPlats) do
      begin
         if (c2 <= RandPlats[i].Y + RandPlats[i].HEIGHT) and (c4 >= RandPlats[i].Y) and (c1 <= RandPlats[i].X + RandPlats[i].WIDTH) and (c3 >= RandPlats[i].X) then
         begin
            hit := true;
         end;
      end;
      if hit = false then
      begin
         help := c1;
      end;
   end;
   until (hit = True) or (c1 >= screenwidth);

   LOSXMax := help;

end;


procedure TAi.WorkOutMoves(player : UPlayer.TPlayer; Bullets : array of TBullet; FixedPlats, RandPlats : Array of TPlat; screenwidth, screenheight : integer);
begin
   //Move Left or right or down and jump starter
   if OnPlat then
      begin
         if TargRand1 then
            begin
               if (RandPlats[TargID1].X > X + PLAYERHEAD) and (RandPlats[TargID1].X + RandPlats[TargID1].Width > X) and (RandPlats[TargID1].Y > Y) then
                  begin
                     doFall();
                  end
               else if (X > RandPlats[TargID1].X + RandPlats[TargID1].Width) then
                  begin
                     Move(MoveCommands.null);
                     if OnRand then
                        begin
                           if (X < RandPlats[PlatID].X) or (X < RandPlats[TargID1].X + RandPlats[TargID1].Width + 50) then
                              begin
                                 doJump();
                                 Y -= 1;
                              end;
                        end
                     else
                        begin
                           if (X < FixedPlats[PlatID].X) or (X < RandPlats[TargID1].X + RandPlats[TargID1].Width + 50) then
                              begin
                                 doJump();
                                 Y -= 1;
                              end;
                        end;
                  end
               else if (X + PLAYERHEAD < RandPlats[TargID1].X) then
                  begin
                     Move(MoveCommands.right);
                     if OnRand then
                        begin
                           if (X + PLAYERHEAD > RandPlats[PlatID].X + RandPlats[PlatID].Width) or (X + PLAYERHEAD > RandPlats[TargID1].X - 50) then
                              begin
                                 doJump();
                                 Y -= 1;
                              end;
                        end
                     else
                        begin
                           if (X + PLAYERHEAD > FixedPlats[PlatID].X + FixedPlats[PlatID].Width) or (X + PLAYERHEAD > RandPlats[TargID1].X - 50) then
                              begin
                                 doJump();
                                 Y -= 1;
                              end;
                        end;
                  end;
            end
         else
            begin
               if (FixedPlats[TargID1].X > X + PLAYERHEAD) and (FixedPlats[TargID1].X + FixedPlats[TargID1].Width > X) and (FixedPlats[TargID1].Y > Y) then
                  begin
                     doFall();
                  end
               else if (X > FixedPlats[TargID1].X + FixedPlats[TargID1].Width) then
                  begin
                     Move(MoveCommands.left);
                     if OnRand then
                        begin
                           if (X < RandPlats[PlatID].X) or (X < FixedPlats[TargID1].X + FixedPlats[TargID1].Width + 50) then
                              begin
                                 doJump();
                                 Y -= 1;
                              end;
                        end
                     else
                        begin
                           if (X < FixedPlats[PlatID].X) or (X < FixedPlats[TargID1].X + FixedPlats[TargID1].Width + 50) then
                              begin
                                 doJump();
                                 Y -= 1;
                              end;
                        end;
                  end
               else if (X + PLAYERHEAD < FixedPlats[TargID1].X) then
                  begin
                     Move(MoveCommands.right);
                     if OnRand then
                        begin
                           if (X + PLAYERHEAD > RandPlats[PlatID].X + RandPlats[PlatID].Width) or (X + PLAYERHEAD > FixedPlats[TargID1].X - 50) then
                              begin
                                 doJump();
                                 Y -= 1;
                              end;
                        end
                     else
                        begin
                           if (X + PLAYERHEAD > FixedPlats[PlatID].X + FixedPlats[PlatID].Width) or (X + PLAYERHEAD > FixedPlats[TargID1].X - 50) then
                              begin
                                 doJump();
                                 Y -= 1;
                              end;
                        end;
                  end;
            end;
      end
   else if (Y - PY < 10) or (Y - PY > -10) then
     begin
       if (X > PX) then
         Move(MoveCommands.left)
       else
         Move(MoveCommands.right);
     end

   //Jump in air
   else if OnPlat = false then
      begin
         if TargRand1 then
            begin
               if (X + PLAYERHEAD >= RandPlats[TargID1].X) and (X <= RandPlats[TargID1].X + RandPlats[TargID1].Width) then
                  begin
                     Move(MoveCommands.null);
                  end
               else
                  begin
                     if (X + PLAYERHEAD < RandPlats[TargID1].X) then
                        begin
                           Move(MoveCommands.right);
                        end
                     else if (X > RandPlats[TargID1].X) then
                        begin
                           Move(MoveCommands.left);
                        end;

                     if (Y > RandPlats[TargID1].Y) then
                        begin
                           doJump();
                           Y -= 1;
                        end;
                  end;
            end
         else
            begin
               if (X + PLAYERHEAD >= FixedPlats[TargID1].X) and (X <= FixedPlats[TargID1].X + FixedPlats[TargID1].Width) then
                  begin
                     Move(MoveCommands.null);
                  end
               else
                  begin
                     if (X + PLAYERHEAD < FixedPlats[TargID1].X) then
                        begin
                           Move(MoveCommands.right);
                        end
                     else if (X > FixedPlats[TargID1].X) then
                        begin
                           Move(MoveCommands.left);
                        end;

                     if (Y > FixedPlats[TargID1].Y) then
                        begin
                           doJump();
                           Y -= 1;
                        end;
                  end;
            end;
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

   //Shoot
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


function TAi.CanJumpTo(FixedPlats, RandPlats : array of TPlat; X, Y : float; TargetID : integer; istargetRand : boolean = true) : boolean;
var
targxmin, targxmax, targy, lastX : float;
testAi : TAi;
counter : integer;
begin
   if istargetRand then
      begin
         targxmin := RandPlats[TargetID].X;
         targxmax := RandPlats[TargetID].X + RandPlats[TargetID].WIDTH;
         targy := RandPlats[TargetID].Y;
      end
   else
      begin
         targxmin := FixedPlats[TargetID].X;
         targxmax := FixedPlats[TargetID].X + FixedPlats[TargetID].WIDTH;
         targy := FixedPlats[TargetID].Y;
      end;

   //Start AI
   testAi := TAi.start();
   testAi.create(X, Y, Colour, 1, FixedPlats, RandPlats);
   repeat
      testAi.isGrounded(maxY, FixedPlats, RandPlats);
      testAi.update(maxX, 1);
   until testAi.AtGround;
   testAi.Move(MoveCommands.null);
   testAi.OnPlatform(FixedPlats, Randplats);

   //Move it to the edge of Platform
   if (testAi.OnPlat) then
      begin
         if (testAi.X < targxmax) and (testAi.X + PLAYERHEAD > targxmin) and (testAi.Y < targy) then
            begin
               testAi.doFall();
            end

         else if (testAi.X > targxmax) then
            begin
               if testAi.OnRand then
                  begin
                     repeat
                        begin
                           testAi.Move(MoveCommands.left);
                           testAi.update(maxX, 1);
                           Counter += 1;
                           if Counter = 4 then
                              begin
                                 LastX := testAi.X;
                                 counter := 0;
                              end;
                        end;
                     until (testAi.X < RandPlats[testAi.PlatID].X) or (testAi.X < targxmax + 50) or ((LastX = testAi.X) and (counter <> 0));
                  end

               else
                  begin
                     repeat
                        begin
                           testAi.Move(MoveCommands.left);
                           testAi.update(maxX, 1);
                           Counter += 1;
                           if Counter = 4 then
                              begin
                                 LastX := testAi.X;
                                 counter := 0;
                              end;
                        end;
                     until (testAi.X < FixedPlats[testAi.PlatID].X) or (testAi.X < targxmax + 50) or ((LastX = testAi.X) and (counter <> 0));
                  end;

               testAi.doJump();
               testAi.Jumps := 1;
               testAi.update(maxX, 1);
               testAi.isGrounded(maxY, FixedPlats, RandPlats);
            end

         else if (testAi.X + PLAYERHEAD < targxmin) then
            begin
               if testAi.OnRand then
                  begin
                     repeat
                        begin
                           testAi.Move(MoveCommands.right);
                           testAi.update(maxX, 1);
                           Counter += 1;
                           if Counter = 4 then
                              begin
                                 LastX := testAi.X;
                                 counter := 0;
                              end;
                        end;
                     until (testAi.X + PLAYERHEAD > RandPlats[testAi.PlatID].X + RandPlats[testAi.PlatID].Width) or (testAi.X + PLAYERHEAD > targxmin - 50) or ((LastX = testAi.X) and (counter <> 0));
                  end

               else
                  begin
                     repeat
                        begin
                           testAi.Move(MoveCommands.right);
                           testAi.update(maxX, 1);
                           Counter += 1;
                           if Counter = 4 then
                              begin
                                 LastX := testAi.X;
                                 counter := 0;
                              end;
                        end;
                     until (testAi.X + PLAYERHEAD > FixedPlats[testAi.PlatID].X + FixedPlats[testAi.PlatID].Width) or (testAi.X + PLAYERHEAD > targxmin - 50) or ((LastX = testAi.X) and (counter <> 0));
                  end;

               testAi.doJump();
               testAi.Jumps := 1;
               testAi.update(maxX, 1);
               testAi.isGrounded(maxY, FixedPlats, RandPlats);
            end;
      end;

   //Simulate Jump
   repeat
      begin
         if (testAi.X + PLAYERHEAD >= targxmin) and (testAi.X <= targxmax) then
            begin
               testAi.Move(MoveCommands.null);
            end

         else
            begin
               if (testAi.X + PLAYERHEAD < targxmin) then
                  begin
                     testAi.Move(MoveCommands.right);
                  end
               else if (testAi.X > targxmax) then
                  begin
                     testAi.Move(MoveCommands.left);
                  end;

               if (testAi.Y > targy) then
                  begin
                     testAi.doJump();
                  end;
            end;

         testAi.update(maxX, 1);
         testAi.isGrounded(maxY, FixedPlats, RandPlats);
      end;
   until (testAi.AtGround) or (testAi.Y > maxY);

   //Evaluate if its on the correct platform
   testAi.OnPlatform(FixedPlats, Randplats);
   if (testAi.PlatID = TargetID) and (testAi.OnRand = istargetRand) then
   begin
      Exit(true);
   end
   else
   begin
      Exit(false);
   end;
end;

end.