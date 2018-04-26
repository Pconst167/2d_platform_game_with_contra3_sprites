unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls;

type
  Tfgame = class(TForm)
    imgPlayerright: TImage;
    imgPlayerleft: TImage;
    imgJumping: TImage;
    imgJumpingBack: TImage;
    imgtmask1: TImage;
    imgtmask2: TImage;
    imgplayermaskright: TImage;
    imgjumpingbackmask: TImage;
    imgjumpingmask: TImage;
    imgEnm1left: TImage;
    imgEnm1leftmask: TImage;
    e8: TImage;
    e4: TImage;
    e3: TImage;
    e2: TImage;
    e1: TImage;
    e5: TImage;
    e6: TImage;
    e7: TImage;
    e16: TImage;
    e12: TImage;
    e11: TImage;
    e10: TImage;
    e9: TImage;
    e13: TImage;
    e14: TImage;
    e15: TImage;
    imgplayermaskleft: TImage;
    Timer1: TTimer;
    imgEnm1right: TImage;
    imgEnm1rightmask: TImage;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

type tsentidox = (esquerda, repousox, direita);
type tsentidoy = (cima, repousoy, baixo);
type ttipoanimacao = (explosao1);

type ttiroHero = record
	x, y, sx, sy : double;
   ativo : boolean;
end;

type ttiroinimigo = record
	x, y, sx, sy : double;
   ativo : boolean;
end;

type thero = record
	x, y : double;
   sy, sx, accel : double;
   sentidox, oldsentidox : tsentidox;
   sentidoy : tsentidoy;
   frames, frame : byte;
   frameloading : byte;
   tirodelay : cardinal;
end;

type tcamera = record
	x1, x2 : double;
   cambmp : tbitmap;
end;

type tbloco = record
	x, y : integer;
   quebravel : boolean;
   solido12h, solido6h, solido3h, solido9h : boolean;
   tilesheetrow, tilesheetcol : cardinal;
end;

type tinimigo = record
	tipo : byte;
	x, y : double;
   sx, sy : double;
   sentidox : tsentidox;
   sentidoy : tsentidoy;
   frame, frames, framedelay: byte;
   ativo : boolean;
   boss : boolean;
   energia : integer;
end;

type tenmsource = record
	enmtype : byte;
   row, col : integer;
   interval : byte;
   ativo : boolean;
end;


type tanimacao = record
	frame, frames: byte;
   tipo : ttipoanimacao;
   ativo: boolean;
   x, y, sx, sy: integer;
end;



const
	TAM = 24;
   TAM_TILE = 16;

	COL = 100;
   LIN = 15;

   LARG_BUFFER = COL * TAM;
   ALT_BUFFER = LIN * TAM;

   CAM_LIN = LIN;
   CAM_COL = 20;

   LARG_CAM = CAM_COL * TAM;
   ALT_CAM = CAM_LIN * TAM;

   LARG_TELA = 800;
   ALT_TELA = 600;

   MAX_ANIM = 100;
   MAX_INIMIGOS = 5;
   MAX_ENMSOURCE = 50;
   MAX_TIROS_INIMIGO = 50;
   MAX_TIROS_HERO = 40;
   
   LARG_HERO = 39;
   ALT_HERO = 43;

   GRAVITY_ACCEL = 0.3;


var
  fgame: Tfgame;

  hero : thero;
  backbuffer : tbitmap;
  blocos : array[0..LIN - 1, 0..COL - 1] of tbloco;
  gamecounter: cardinal;
  animacoes : array[1..MAX_ANIM] of tanimacao;
  camera : tcamera;
  tirosHero : array[1..MAX_TIROS_HERO] of ttirohero;
  tirosinimigo : array[1..MAX_TIROS_INIMIGO] of ttiroinimigo;
  inimigos : array[1..MAX_INIMIGOS] of tinimigo;
  enmsource : array[1..MAX_ENMSOURCE] of tenmsource;
  drawcounter,FPS: cardinal;

  tilesetbmp : tbitmap;

implementation

{$R *.dfm}

function negpos : integer;
var
	i : byte;
begin
	randomize;
   i := random(2);

   if i = 0 then result := -1
   else result := 1;
end;

procedure debug(s: string);
begin
	showmessage(s);
end;

procedure addEnemy(tipo : byte; x, y, sx : double);
var
	i : cardinal;
begin
	for i := 1 to MAX_INIMIGOS do
   	if not inimigos[i].ativo then
      begin
      	inimigos[i].ativo := true;
         inimigos[i].tipo := tipo;
         inimigos[i].x := x;
         inimigos[i].y := y;
         inimigos[i].sx := sx;
         inimigos[i].frame := 1;
         inimigos[i].frames := 3;
        	inimigos[i].energia := 1;

         break;
      end;
end;

procedure activateEnmSources;
var
	i, c : cardinal;
begin
   c := trunc(hero.x) div TAM;
   
	for i := 1 to MAX_ENMSOURCE do
   	if enmsource[i].row <> -1 then
      	if abs(enmsource[i].col - c) < 10 then
      		if gamecounter mod 200 = 0 then
         		addEnemy(1, enmsource[i].col * TAM, enmsource[i].row * TAM, negpos());
end;

procedure inimigoatira(x, y, sx, sy : double);
var
	i : cardinal;
begin
	for i := 1 to MAX_TIROS_INIMIGO do
   	if not tirosinimigo[i].ativo then
      begin
      	tirosinimigo[i].ativo := true;
         tirosinimigo[i].x := x;
         tirosinimigo[i].y := y;
         tirosinimigo[i].sx := sx;
         tirosinimigo[i].sy := sy;
         break;
      end;
end;

procedure moverinimigos;
var
	i : cardinal;
   novox, novoy : double;
   l, c : integer;
begin
	for i := 1 to MAX_INIMIGOS do
   	if inimigos[i].ativo then
      begin
      	if inimigos[i].framedelay = 0 then
         begin
         	if inimigos[i].frame < inimigos[i].frames then inc(inimigos[i].frame)
            else inimigos[i].frame := 1;
            inimigos[i].framedelay := 10;
         end;
         dec(inimigos[i].framedelay);

			l := trunc(inimigos[i].y) div TAM;
         c := trunc(inimigos[i].x) div TAM;

         novox := inimigos[i].x + inimigos[i].sx;

         if novox <= 0 then novox := 0
         else if novox >= LARG_BUFFER - 1 then novox := LARG_BUFFER - 1;

         novoy := inimigos[i].y;
         if inimigos[i].sentidoy <> repousoy then
         begin
            novoy := novoy + inimigos[i].sy;
            inimigos[i].sy := inimigos[i].sy + GRAVITY_ACCEL;
         end;

         if novoy <= 0 then novoy := 0
         else if novoy + 41 >= ALT_BUFFER then
         begin
            novox := 30;
            novoy := 0;

            inimigos[i].sy := 3;
      		inimigos[i].sentidoy := baixo;
         end;

      // contato pela esquerda

         if (l >= 0) and (c >= 0) and (l + 2 < LIN) and (c + 2 < COL) then
            if (blocos[l + 2, c + 2].solido9h) and (inimigos[i].y + 44 > blocos[l + 2, c + 2].y) then
            begin
               if novox + 30 > blocos[l + 2, c + 2].x then
               begin
                  novox := blocos[l + 2, c + 2].x - 30;
                  inimigos[i].sx := -inimigos[i].sx;
               end;
            end
            else if blocos[l + 1, c + 2].solido9h then
            begin
               if novox + 30 > blocos[l + 1, c + 2].x then
               begin
                  novox := blocos[l + 1, c + 2].x - 30;
                  inimigos[i].sx := -inimigos[i].sx;
               end;
            end
            else if blocos[l, c + 2].solido9h then
            begin
               if novox + 30 > blocos[l, c + 2].x then
               begin
                  novox := blocos[l, c + 2].x - 30;
                  inimigos[i].sx := -inimigos[i].sx;
               end;
            end;

      // contato pela direita
         if (l >= 0) and (l + 2 < LIN) and (c - 1 >= 0) and (c - 1 < COL) then
            if (blocos[l + 2, c - 1].solido3h) and (inimigos[i].y + 44 > blocos[l + 2, c - 1].y) then
            begin
               if novox < blocos[l + 2, c - 1].x + TAM then
               begin
                  novox := blocos[l + 2, c - 1].x + TAM;
                  inimigos[i].sx := -inimigos[i].sx;
               end
            end
            else if blocos[l + 1, c - 1].solido3h then
            begin
               if novox < blocos[l + 1, c - 1].x + TAM then
               begin
                  novox := blocos[l + 1, c - 1].x + TAM;
                  inimigos[i].sx := -inimigos[i].sx;
               end
            end
            else if blocos[l, c - 1].solido3h then
            begin
               if novox < blocos[l, c - 1].x + TAM then
               begin
                  novox := blocos[l, c - 1].x + TAM;
                  inimigos[i].sx := -inimigos[i].sx;
               end;
            end;



      // contato por cima
         if (l >= 0) and (l + 2 < LIN) and (c + 2 < COL) and (c >= 0) then
            if (blocos[l + 2, c + 2].solido12h) and (inimigos[i].x + 30 > blocos[l + 2, c + 2].x) then
            begin
               if novoy + 44 > blocos[l + 2, c + 2].y then
               begin
                  novoy := blocos[l + 2, c + 2].y - 44;
                  inimigos[i].sy := 0;
                  inimigos[i].sentidoy := repousoy;
               end;
            end
            else if blocos[l + 2, c + 1].solido12h then
            begin
               if novoy + 44 > blocos[l + 2, c + 1].y then
               begin
                  novoy := blocos[l + 2, c + 1].y - 44;
                  inimigos[i].sy := 0;
                  inimigos[i].sentidoy := repousoy;
               end;
            end
            else if blocos[l + 2, c].solido12h then
            begin
               if novoy + 44 > blocos[l + 2, c].y then
               begin
                  novoy := blocos[l + 2, c].y - 44;
                  inimigos[i].sy := 0;
                  inimigos[i].sentidoy := repousoy;
               end;
            end
            else
            begin
               inimigos[i].sentidoy := baixo;
            end;


         // contato por baixo

         if (l - 1 >= 0) and (c + 2 < COL) and (c >=0 ) and (l - 1 < LIN) then
            if blocos[l - 1, c].solido6h then
            begin
               if novoy < blocos[l - 1, c].y + TAM then
               begin
                  novoy := blocos[l - 1, c].y + TAM;
                  inimigos[i].sy := 3;
                  inimigos[i].sentidoy := baixo;
               end;
            end
            else if (blocos[l - 1, c + 1].solido6h) then
            begin
               if novoy < blocos[l - 1, c + 1].y + TAM then
               begin
                  novoy := blocos[l - 1, c + 1].y + TAM;
                  inimigos[i].sy := 3;
                  inimigos[i].sentidoy := baixo;
               end;
            end
            else if (blocos[l - 1, c + 2].solido6h) and (hero.x + 34 > blocos[l - 1, c + 2].x) then
            begin
               if novoy < blocos[l - 1, c + 2].y + TAM then
               begin
                  novoy := blocos[l - 1, c + 2].y + TAM;
                  inimigos[i].sy := 3;
                  inimigos[i].sentidoy := baixo;
               end;
            end;


         inimigos[i].x := novox;
         inimigos[i].y := novoy;

         if inimigos[i].x <= 0 then inimigos[i].ativo := false;
         if inimigos[i].x >= LARG_BUFFER - 1 then inimigos[i].ativo := false;
         if trunc(inimigos[i].x) mod 200 = 0 then inimigoatira(inimigos[i].x, inimigos[i].y + 15, inimigos[i].sx * 3, 0);
      end;
end;

procedure loadstage;
var
	i, j: cardinal;
   stagefile : file of tbloco;
   enmfile : file of tenmsource;
   enm : tenmsource;
   b : tbloco;
begin
	filemode := fmopenread;

   assignfile(stagefile, 'stage1.stg');
   reset(stagefile);

   for i := 0 to LIN - 1 do
   	for j := 0 to COL - 1 do
      begin
      	if not eof(stagefile) then read(stagefile, b);
         blocos[i, j] := b;
         blocos[i, j].y := i * TAM;
         blocos[i, j].x := j * TAM;
      end;

   closefile(stagefile);

   filemode := fmopenread;
   assignfile(enmfile, 'stage1.enm');
   reset(enmfile);

   for i := 1 to MAX_ENMSOURCE do
   begin
   	read(enmfile, enm);

      enmsource[i].enmtype := enm.enmtype;
      enmsource[i].row := enm.row;
      enmsource[i].col := enm.col;
      enmsource[i].interval := enm.interval;
   end;

   closefile(enmfile);
end;

procedure atirar;
var
	i : cardinal;
begin
	for i := 1 to MAX_TIROS_HERO do
		if not tiroshero[i].ativo then
		begin
      	tiroshero[i].ativo := true;
			tiroshero[i].x := hero.x + 18;
         tiroshero[i].y := hero.y + 10;
         if hero.oldsentidox = esquerda then tiroshero[i].sx := -10
         else tiroshero[i].sx := 10;
         break;
		end;
end;


procedure atualizarAnimacoes();
var
	i: integer;
begin

	if gamecounter mod 3 = 0 then
   begin
   	for i := 1 to MAX_ANIM do
			if animacoes[i].ativo then
         begin
      		if animacoes[i].frame < animacoes[i].frames then
         		Inc(animacoes[i].frame)
         	else
         		animacoes[i].ativo := false;
         end;
   end;

end;


procedure inserirAnimacao(x, y: real; tipo: ttipoanimacao);
var
	i: integer;
begin;
	for i := 1 to MAX_ANIM do
   begin
   	if animacoes[i].ativo = false then
      begin
      	animacoes[i].tipo := tipo;
      	animacoes[i].ativo := true;
      	animacoes[i].frame := 1;
        	animacoes[i].x := trunc(x);
        	animacoes[i].y := trunc(y);


         case tipo of
         	explosao1: animacoes[i].frames := 16;

         end;
        	break;
      end;
   end;
end;





procedure movertiroshero;
var
	i, j : cardinal;
   l, c : integer;
begin
	randomize;
	for i := 1 to MAX_TIROS_HERO do
		if tiroshero[i].ativo then
		begin
      	tiroshero[i].x := tiroshero[i].x + tiroshero[i].sx;
         if abs(tiroshero[i].x - hero.x) > LARG_CAM then tiroshero[i].ativo := false;

      	for j := 1 to MAX_INIMIGOS do
         	if inimigos[j].ativo then
            	if (tiroshero[i].x + 6 > inimigos[j].x)
               and (tiroshero[i].y + 6 > inimigos[j].y)
               and (tiroshero[i].x < inimigos[j].x + 34)
               and (tiroshero[i].y < inimigos[j].y + 40) then
               begin
               	tiroshero[i].ativo := false;
                  inimigos[j].ativo := false;
                  inserirAnimacao(inimigos[j].x + negpos * random(10), inimigos[j].y + negpos * random(10), explosao1);
                  inserirAnimacao(inimigos[j].x + negpos * random(10), inimigos[j].y + negpos * random(10), explosao1);
                  inserirAnimacao(inimigos[j].x + negpos * random(10), inimigos[j].y + negpos * random(10), explosao1);
                  inserirAnimacao(inimigos[j].x + negpos * random(10), inimigos[j].y + negpos * random(10), explosao1);
                  break;
               end;

         l := trunc(tiroshero[i].y) div TAM;
         c := trunc(tiroshero[i].x) div TAM;

         if (l >= 0) and (l < LIN) and (c >= 0) and (c < COL) then
         	if (blocos[l, c].solido12h) or (blocos[l, c].solido3h) or (blocos[l, c].solido6h) or (blocos[l, c].solido9h) then
            begin
         		tiroshero[i].ativo := false;

               if blocos[l, c].quebravel then
               begin
               	blocos[l, c].tilesheetrow := 0;
                  blocos[l, c].tilesheetcol := 0;
                  blocos[l, c].solido12h := false;
                  blocos[l, c].solido3h := false;
                  blocos[l, c].solido6h := false;
                  blocos[l, c].solido9h := false;
               end;
               inseriranimacao(trunc(tiroshero[i].x) - 16 + negpos * random(10), trunc(tiroshero[i].y) - 16 + negpos * random(10), explosao1);
            end;
		end;
end;

procedure movertirosinimigo;
var
	i : cardinal;
   l, c : integer;
begin
	randomize;
	for i := 1 to MAX_TIROS_INIMIGO do
		if tirosinimigo[i].ativo then
		begin
      	l := trunc(tirosinimigo[i].y) div TAM;
         c := trunc(tirosinimigo[i].x) div TAM;
      	tirosinimigo[i].x := tirosinimigo[i].x + tirosinimigo[i].sx;
         if (tirosinimigo[i].x <= 0) or (tirosinimigo[i].x >= LARG_BUFFER) then tirosinimigo[i].ativo := false;

         if (l >= 0) and (l < LIN) and (c >= 0) and (c < COL) then
            if (blocos[l, c].solido12h) or (blocos[l, c].solido3h) or (blocos[l, c].solido6h) or (blocos[l, c].solido9h) then
            begin
               tirosinimigo[i].ativo := false;
               inseriranimacao(trunc(tirosinimigo[i].x) - 16 + negpos * random(10), trunc(tirosinimigo[i].y) - 16 + negpos * random(10), explosao1);
            end;
		end;
end;

procedure desenhar(x, y : double; bmp : tbitmap);
begin
	backbuffer.canvas.draw(trunc(x), trunc(y), bmp);
end;

procedure desenharcenario;
var
	i, j : cardinal;
   //i1, i2, j1, j2 : cardinal;       // para a camera mais tarde
begin
	for i := 0 to LIN - 1 do
   	for j := ( trunc(camera.x1) div TAM ) to ( trunc(camera.x2) div TAM) do
      	stretchblt(backbuffer.canvas.Handle, blocos[i, j].x, blocos[i, j].y, TAM, TAM, tilesetbmp.canvas.Handle, blocos[i, j].tilesheetcol * TAM_TILE, blocos[i, j].tilesheetrow * TAM_TILE, TAM_TILE, TAM_TILE, srccopy);

   for i := 1 to MAX_TIROS_HERO do
   	if tiroshero[i].ativo then
      begin
      	bitblt(backbuffer.canvas.Handle, trunc(tiroshero[i].x), trunc(tiroshero[i].y), 8, 6, fgame.imgtmask1.canvas.Handle, 0, 0, srcand);
         bitblt(backbuffer.canvas.Handle, trunc(tiroshero[i].x), trunc(tiroshero[i].y), 8, 6, fgame.imgtmask2.canvas.Handle, 0, 0, srcpaint);
   	end;

   for i := 1 to MAX_TIROS_INIMIGO do
   	if tirosinimigo[i].ativo then
      begin
      	bitblt(backbuffer.canvas.Handle, trunc(tirosinimigo[i].x), trunc(tirosinimigo[i].y), 8, 6, fgame.imgtmask1.canvas.Handle, 0, 0, srcand);
         bitblt(backbuffer.canvas.Handle, trunc(tirosinimigo[i].x), trunc(tirosinimigo[i].y), 8, 6, fgame.imgtmask2.canvas.Handle, 0, 0, srcpaint);
   	end;

   for i := 1 to MAX_INIMIGOS do
   	if inimigos[i].ativo then
      	if inimigos[i].sx < 0 then
         begin
      		stretchblt(backbuffer.canvas.Handle, trunc(inimigos[i].x), trunc(inimigos[i].y), 35, 44, fgame.imgEnm1leftmask.canvas.Handle, (inimigos[i].frame - 1) * 35, 0, 32, 40, srcand);
         	stretchblt(backbuffer.canvas.Handle, trunc(inimigos[i].x), trunc(inimigos[i].y), 35, 44, fgame.imgEnm1left.canvas.Handle, (inimigos[i].frame - 1) * 35, 0, 32, 40, srcpaint);
         end
      	else
         begin
         	stretchblt(backbuffer.canvas.Handle, trunc(inimigos[i].x), trunc(inimigos[i].y), 35, 44, fgame.imgEnm1rightmask.canvas.Handle, (inimigos[i].frame - 1) * 35, 0, 32, 40, srcand);
         	stretchblt(backbuffer.canvas.Handle, trunc(inimigos[i].x), trunc(inimigos[i].y), 35, 44, fgame.imgEnm1right.canvas.Handle, (inimigos[i].frame - 1) * 35, 0, 32, 40, srcpaint);
         end;

   if hero.sx = 0 then
   begin
   	if hero.oldsentidox = esquerda then
      	if hero.sentidoy <> repousoy then
         begin
         	bitblt(backbuffer.canvas.Handle, trunc(hero.x), trunc(hero.y), 22, 25, fgame.imgJumpingbackmask.canvas.Handle, 88 - (hero.frame)*22, 0, srcand);
            bitblt(backbuffer.canvas.Handle, trunc(hero.x), trunc(hero.y), 22, 25, fgame.imgJumpingback.canvas.Handle, 88 - (hero.frame)*22, 0, srcpaint);
         end
			else
         begin
         	stretchblt(backbuffer.canvas.Handle, trunc(hero.x), trunc(hero.y), LARG_HERO, ALT_HERO, fgame.imgPlayermaskleft.canvas.Handle, 0, 0, 36, 40, srcand);
            stretchblt(backbuffer.canvas.Handle, trunc(hero.x), trunc(hero.y), LARG_HERO, ALT_HERO, fgame.imgPlayerleft.canvas.Handle, 0, 0, 36, 40, srcpaint);
         end
      else
      	if hero.sentidoy <> repousoy then
         begin
      		bitblt(backbuffer.canvas.Handle, trunc(hero.x), trunc(hero.y), 22, 25, fgame.imgJumpingmask.canvas.Handle, (hero.frame-1)*22, 0, srcand);
            bitblt(backbuffer.canvas.Handle, trunc(hero.x), trunc(hero.y), 22, 25, fgame.imgJumping.canvas.Handle, (hero.frame-1)*22, 0, srcpaint);
         end
         else
         begin
         	stretchblt(backbuffer.canvas.Handle, trunc(hero.x), trunc(hero.y), LARG_HERO, ALT_HERO, fgame.imgPlayermaskright.canvas.Handle, 144, 0, 33, 40, srcand);
            stretchblt(backbuffer.canvas.Handle, trunc(hero.x), trunc(hero.y), LARG_HERO, ALT_HERO, fgame.imgPlayerright.canvas.Handle, 144, 0, 33, 40, srcpaint);
         end
   end
   else
   begin
   	if (hero.oldsentidox = direita) then
      	if hero.sentidoy <> repousoy then
         begin
   			stretchblt(backbuffer.canvas.Handle, trunc(hero.x), trunc(hero.y), LARG_HERO - 15, ALT_HERO - 15, fgame.imgJumpingmask.canvas.Handle, (hero.frame - 1) * 22, 0, 22, 25, srcand);
         	stretchblt(backbuffer.canvas.Handle, trunc(hero.x), trunc(hero.y), LARG_HERO - 15, ALT_HERO - 15, fgame.imgJumping.canvas.Handle, (hero.frame - 1) * 22, 0, 22, 25, srcpaint);
         end
         else
         begin
         	stretchblt(backbuffer.canvas.Handle, trunc(hero.x), trunc(hero.y), LARG_HERO, ALT_HERO, fgame.imgPlayermaskright.canvas.Handle, (hero.frame - 1) * 36, 0, 36, 38, srcand);
            stretchblt(backbuffer.canvas.Handle, trunc(hero.x), trunc(hero.y), LARG_HERO, ALT_HERO, fgame.imgPlayerright.canvas.Handle, (hero.frame - 1) * 36, 0, 36, 38, srcpaint);
         end
      else
      	if hero.sentidoy <> repousoy then
         begin
   			stretchblt(backbuffer.canvas.Handle, trunc(hero.x), trunc(hero.y), LARG_HERO - 15, ALT_HERO - 15, fgame.imgJumpingbackmask.canvas.Handle, (hero.frame - 1) * 22, 0, 22, 25, srcand);
         	stretchblt(backbuffer.canvas.Handle, trunc(hero.x), trunc(hero.y), LARG_HERO - 15, ALT_HERO - 15, fgame.imgJumpingback.canvas.Handle, (hero.frame - 1) * 22, 0, 22, 25, srcpaint);
         end
         else
         begin
         	stretchblt(backbuffer.canvas.Handle, trunc(hero.x), trunc(hero.y), LARG_HERO, ALT_HERO, fgame.imgPlayermaskleft.canvas.Handle, 180 - (hero.frame) * 36, 0, 33, 38, srcand);
            stretchblt(backbuffer.canvas.Handle, trunc(hero.x), trunc(hero.y), LARG_HERO, ALT_HERO, fgame.imgPlayerleft.canvas.Handle, 180 - (hero.frame) * 36, 0, 33, 38, srcpaint);
         end
	end;


   for i:= 1 to MAX_ANIM do
      if animacoes[i].ativo then
         case animacoes[i].tipo of
            explosao1:
            case animacoes[i].frame of
                  1: desenhar(animacoes[i].x, animacoes[i].y, fgame.e1.Picture.Bitmap);
                  2: desenhar(animacoes[i].x, animacoes[i].y, fgame.e2.Picture.Bitmap);
                  3: desenhar(animacoes[i].x, animacoes[i].y, fgame.e3.Picture.Bitmap);
                  4: desenhar(animacoes[i].x, animacoes[i].y, fgame.e4.Picture.Bitmap);
                  5: desenhar(animacoes[i].x, animacoes[i].y, fgame.e5.Picture.Bitmap);
                  6: desenhar(animacoes[i].x, animacoes[i].y, fgame.e6.Picture.Bitmap);
                  7: desenhar(animacoes[i].x, animacoes[i].y, fgame.e7.Picture.Bitmap);
                  8: desenhar(animacoes[i].x, animacoes[i].y, fgame.e8.Picture.Bitmap);
                  9: desenhar(animacoes[i].x, animacoes[i].y, fgame.e9.Picture.Bitmap);
                  10: desenhar(animacoes[i].x, animacoes[i].y, fgame.e10.Picture.Bitmap);
                  11: desenhar(animacoes[i].x, animacoes[i].y, fgame.e11.Picture.Bitmap);
                  12: desenhar(animacoes[i].x, animacoes[i].y, fgame.e12.Picture.Bitmap);
                  13: desenhar(animacoes[i].x, animacoes[i].y, fgame.e13.Picture.Bitmap);
                  14: desenhar(animacoes[i].x, animacoes[i].y, fgame.e14.Picture.Bitmap);
                  15: desenhar(animacoes[i].x, animacoes[i].y, fgame.e15.Picture.Bitmap);
                  16: desenhar(animacoes[i].x, animacoes[i].y, fgame.e16.Picture.Bitmap);
                end;
         end;

   //backbuffer.Canvas.TextOut(trunc(hero.x),trunc(hero.y)-10,inttostr(hero.frame));


end;

procedure SetScreenResolution(const width, height, colorDepth : integer); overload;
var
	mode:TDevMode;
begin
	zeroMemory(@mode, sizeof(TDevMode));
	mode.dmSize := sizeof(TDevMode);
  	mode.dmPelsWidth := width;
  	mode.dmPelsHeight := height;
  	mode.dmBitsPerPel := colorDepth;
  	mode.dmFields := DM_PELSWIDTH or DM_PELSHEIGHT or DM_BITSPERPEL;
  	ChangeDisplaySettings(mode, 0);
end;

procedure Tfgame.FormCreate(Sender: TObject);
begin
	tilesetbmp := tbitmap.create;
   tilesetbmp.LoadFromFile('tileset.bmp');

	backbuffer := tbitmap.create;
   backbuffer.width := TAM * COL;
   backbuffer.Height := TAM * LIN;
   backbuffer.canvas.font.color:=clwhite;
   backbuffer.canvas.brush.color := clblack;

   camera.cambmp := tbitmap.create;
   camera.cambmp.Width := LARG_CAM;
   camera.cambmp.height := ALT_CAM;
   camera.cambmp.canvas.font.color := clwhite;
   camera.cambmp.Canvas.Brush.color:=clnavy;
   width := LARG_TELA;
   height := ALT_TELA + 24;

   hero.y := 40;
   hero.x := CAM_COL*TAM div 2 -80;
   hero.frames:=4;
   hero.frame:=1;
   hero.sy:=0;
   hero.sentidoy:=baixo;
   hero.oldsentidox:=direita;


end;



procedure Tfgame.FormDestroy(Sender: TObject);
begin
	tilesetbmp.free;
	backbuffer.Free;
   camera.cambmp.Free;
end;

procedure movercamera;
begin
	if hero.x - LARG_CAM div 2 <= 0 then
   	camera.x1 := 0
   else camera.x1 := hero.x - LARG_CAM div 2;

   if hero.x + LARG_CAM div 2 > COL * TAM then
   begin
   	camera.x2 := COL * TAM;
      camera.x1 := COL * TAM - LARG_CAM;
   end
   else if hero.x - LARG_CAM div 2 <= 0 then
   	camera.x2:=LARG_CAM
   else camera.x2 := hero.x + LARG_CAM div 2;
end;

procedure lerteclado;
begin
	if getkeystate(vk_escape) < 0 then application.Terminate;
	if getkeystate(vk_left) < 0 then
   begin
      hero.oldsentidox := esquerda;
   	hero.sentidox := esquerda;
   end
   else if getkeystate(vk_right) < 0 then
   begin
   	hero.sentidox := direita;
      hero.oldsentidox := direita;
   end
   else hero.sentidox := repousox;


   {if getkeystate(vk_down) < 0 then hero.posicao := abaixado
   else hero.posicao := emposicao;
    }

   if hero.sentidoy = repousoy then
   	if getkeystate(90) < 0 then
   	begin
         hero.sentidoy:=cima;
         hero.sy:= -8;
   	end;

   if getkeystate(65) < 0 then
      if hero.tirodelay = 0 then
      begin
         hero.tirodelay := 5;
         atirar;
      end;
end;




procedure moverHero;
var
	l, c : integer;
   novox, novoy : double;
begin
	l := trunc(hero.y) div TAM;
   c := trunc(hero.x) div TAM;


   if gamecounter mod 1 = 0 then
   begin
      if hero.sentidox = esquerda then
      begin
      	if hero.sx > -3 then hero.sx := hero.sx - hero.accel;
      end
      else if hero.sentidox = direita then
      begin
      	if hero.sx < 3 then
         	hero.sx := hero.sx + hero.accel;
      end
      else if hero.sentidoy = repousoy then
      begin
         if hero.sx > 0 then hero.sx := hero.sx - hero.accel
         else if hero.sx < 0 then hero.sx := hero.sx + hero.accel;
      end;
   end;


	novox := hero.x + hero.sx;

   if novox <= 0 then novox := 0
   else if novox + LARG_HERO >= LARG_BUFFER - TAM then novox := LARG_BUFFER - LARG_HERO - TAM;

   novoy := hero.y;
   if hero.sentidoy <> repousoy then
   begin
      novoy := novoy + hero.sy;
   	hero.sy := hero.sy + GRAVITY_ACCEL;
   end;

   if novoy <= 0 then novoy := 0
   else if novoy + ALT_HERO >= ALT_BUFFER then
   begin
   	novox := 30;
   	novoy := 0;

      hero.sy := 3;
   end;


// contato pela esquerda

	if (l + 2 < LIN) and (l >= 0) and (c + 2 < COL) and (c + 2 >= 0) then
      if (blocos[l + 2, c + 2].solido9h) and (hero.y + ALT_HERO - 2 > blocos[l + 2, c + 2].y) then
      begin
         if novox + LARG_HERO > blocos[l + 2, c + 2].x then
            novox := blocos[l + 2, c + 2].x - LARG_HERO;
      end
      else if (blocos[l + 1, c + 2].solido9h) then
      begin
         if novox + LARG_HERO > blocos[l + 1, c + 2].x then
            novox := blocos[l + 1, c + 2].x - LARG_HERO;
      end
      else if (blocos[l, c + 2].solido9h) then
      begin
         if novox + LARG_HERO > blocos[l, c + 2].x then
            novox := blocos[l, c + 2].x - LARG_HERO;
      end;

// contato pela direita
	if (l + 2 < LIN) and (l >= 0) and (c - 1 >= 0) and (c - 1 < COL) then
      if (blocos[l + 2, c - 1].solido3h) and (hero.y + ALT_HERO > blocos[l + 2, c - 1].y) then
      begin
      if novox < blocos[l + 2, c - 1].x + TAM then
      	novox := blocos[l + 2, c - 1].x + TAM;
      end
      else if (blocos[l + 1, c - 1].solido3h) then
      begin
      if novox < blocos[l + 1, c - 1].x + TAM then
         novox := blocos[l + 1, c - 1].x + TAM;
      end
      else if (blocos[l, c - 1].solido3h) then
      begin
      if novox < blocos[l, c - 1].x + TAM then
         novox := blocos[l, c - 1].x + TAM;
		end;



// contato por cima
   if (l + 2 < LIN) and (l + 2 >= 0) and (c + 2 < COL) and (c >= 0) then
      if (blocos[l + 2, c + 2].solido12h) and (hero.x + LARG_HERO > blocos[l + 2, c + 2].x) then
      begin
         if novoy + ALT_HERO > blocos[l + 2, c + 2].y then
         begin
            novoy := blocos[l + 2, c + 2].y - ALT_HERO;
            hero.sy := 0;
            hero.sentidoy := repousoy;
         end;
      end
      else if (blocos[l + 2, c + 1].solido12h) then
      begin
         if novoy + ALT_HERO > blocos[l + 2, c + 1].y then
         begin
            novoy := blocos[l + 2, c + 1].y - ALT_HERO;
            hero.sy := 0;
            hero.sentidoy := repousoy;
         end;
      end
      else if (blocos[l + 2, c].solido12h) then
      begin
         if novoy + ALT_HERO > blocos[l + 2, c].y then
         begin
            novoy := blocos[l + 2, c].y - ALT_HERO;
            hero.sy := 0;
            hero.sentidoy := repousoy;
         end;
      end
      else
      begin
         hero.sentidoy := baixo;
      end;

// contato por baixo

	if (l - 1 >= 0) and (l - 1 < LIN) and (c + 2 < COL) and (c >= 0) then
      if (blocos[l - 1, c].solido6h) then
      begin
         if novoy < blocos[l - 1, c].y + TAM then
         begin
            novoy := blocos[l - 1, c].y + TAM;
            hero.sy := 3;
            hero.sentidoy := baixo;
         end;
      end
      else if (blocos[l - 1, c + 1].solido6h) then
      begin
         if novoy < blocos[l - 1, c + 1].y + TAM then
         begin
            novoy := blocos[l - 1, c + 1].y + TAM;
            hero.sy := 3;
            hero.sentidoy := baixo;
         end;
      end
      else if (blocos[l - 1, c + 2].solido6h) and (hero.x + LARG_HERO > blocos[l - 1, c + 2].x) then
      begin
         if novoy < blocos[l - 1, c + 2].y + TAM then
         begin
            novoy := blocos[l - 1, c + 2].y + TAM;
            hero.sy := 3;
            hero.sentidoy := baixo;
         end;
      end;

   if (hero.sx <> 0) or (hero.sentidoy <> repousoy) then
   begin
   	if hero.frameloading = 0 then
      begin
      	if hero.frame < hero.frames then
         inc(hero.frame)
         else hero.frame:=1;
         if hero.sentidoy  <> repousoy then
         	hero.frameloading := 5
         else
         	hero.frameloading := trunc(10 - (5/5) * abs(hero.sx));
      end;
      dec(hero.frameloading);
   end;

   hero.x := novox;
   hero.y := novoy;

   if hero.tirodelay > 0 then dec(hero.tirodelay);
end;

procedure Desenharcamera;
begin
	bitblt(camera.cambmp.canvas.handle, 0, 0, trunc(camera.x2 - camera.x1), ALT_CAM, backbuffer.canvas.handle, trunc(camera.x1), 0, srccopy);
   camera.cambmp.canvas.textout(0, 20, floattostr((hero.sx) ));
   camera.cambmp.canvas.textout(0, 50, inttostr(hero.frame));
 {
   camera.cambmp.canvas.textout(0, 20, floattostr((hero.x) ));
   camera.cambmp.canvas.textout(0, 40,floattostr((trunc(hero.y)) div TAM ));
   camera.cambmp.canvas.textout(0, 60, inttostr(trunc(hero.x) div TAM));

   if hero.sentidoy <> repousoy then
         camera.cambmp.Canvas.TextOut(0,0,'true')
         else camera.cambmp.Canvas.TextOut(0,0,'false');
         camera.cambmp.canvas.TextOut(100,0,inttostr(gamecounter));
         camera.cambmp.canvas.TextOut(200,0,floattostr(camera.x1));
         camera.cambmp.canvas.TextOut(300,0,floattostr(camera.x2));

   l := trunc(hero.y) div TAM;
   c := trunc(hero.x) div TAM;

	camera.cambmp.canvas.textout(200, 60, 'lin:'+inttostr(l));
   camera.cambmp.canvas.textout(200, 80, 'col:'+inttostr(c));
   camera.cambmp.canvas.textout(200, 100, floattostr(hero.sy));
   camera.cambmp.Canvas.TextOut(0,100,'FPS:'+inttostr(FPS));
     }
end;

procedure desenharTelaFinal;
begin
	stretchblt(fgame.canvas.handle, 0, 0, LARG_TELA, ALT_TELA, camera.cambmp.canvas.handle, 0, 0, LARG_CAM, ALT_CAM, srccopy);
end;

procedure Tfgame.FormActivate(Sender: TObject);
var
	oldcount : cardinal;
begin
	loadstage;
   oldcount := gettickcount;
   hero.sx := 0;
   hero.accel := 1;

	while not application.Terminated do
   begin
   	if gettickcount - oldcount < 15 then continue;
      	lerteclado();
         moverHero();
         movertiroshero();

         moverinimigos();
         movertirosinimigo();

         activateEnmSources;

         atualizaranimacoes();
         movercamera();
         desenharcenario;
         desenharcamera();

         desenharTelaFinal();
         inc(gamecounter);


         oldcount := gettickcount;
         inc(drawcounter);
         application.ProcessMessages;
   end;
end;

procedure Tfgame.Timer1Timer(Sender: TObject);
begin
	FPS:=drawcounter;
   drawcounter:=0;
end;

end.
