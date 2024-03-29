#include "inkey.ch"
#include "Mater.ch"
/////////////////////////////////////////////////////////////////////
Local oMenMain, Omen, data, nameexe := S_ExeName() 
Local aDir:= {"BAZA","WORK","ARXIV"}, i
Set procedure to pubNsi.prg
Set procedure to jramat.prg
Set procedure to jraVed.prg

ErrorBlock( { |ObjError| M_Error(ObjError) } )
Set(26,.f.)                      // Ŀ
Set(32,.f.)                      //  �  ������ ���㬥����
Set(4,"dd.mm.yyyy")              //  �� �� Clipper 5.0
Set(11,.t.)                      //  �
Set(9,.f.)                       //  �
SetBlink(.t.)                    // ��
S_SetDelay(15)
aSize(Sset,SSET_LEN)
sset[SSET_LEN]   := {"S_Ent","S_Chet","Prixod","Rasxod","OstMat","akt",;
                     "S_mat","Baza","OstMatM"}
sset[SSET_NAIM] := " "
sset[SSET_DATA] := date()
sset[SSET_DIR6] := ""
sset[SSET_DIRTN] := ""
DeskTop := oKMouseNew()
oNorton := oNortonNew()
DeskTop:Norton := oNorton
DeskTop:Open()
// �஢�ਬ ��४�ਨ
For i:= 1 to Len(aDir)
  cDir := S_GetDrive(NameExe)+s_GetPath(NameExe)+aDir[i]
  if !S_IsDir(cDir)
      S_MakeDir(cDir)
  end
  sset[SSET_DIR+i] := cDir+"\"
next
SetColor(sset[86] := "n/w")
S_cls("�")
@ 00,00 say padc(" ",80)
@ 00,57 say "�६�:"
S_ShowTime(0,64,.F.,"n/w")
@ 00, 01 say sset[SSET_NAIM]
S_Nil_Key()
S_SetKey(K_CTRL_F9, { |x| x := Set(4,"dd.mm.yy"),;
                          S_Calend(3,50),;
                          Set(4,x) },"������" )
S_SetKey(K_CTRL_F10, { | |S_Calc() },"�����" )
oMen := MainMenu()
BEGIN SEQUENCE
VVodData()
if File(sset[SSET_BAZA]+"Dirgo6.!!!")
 key := S_ArRest(sset[SSET_BAZA]+"Dirgo6.!!!")
 sset[SSET_DIR6]  := alltrim(key[1])
 sset[SSET_DIRTN] := alltrim(key[2])
End
sset[SSET_BUM] := 1
omen:refAll()
// ������� ����� ��������� ��쥪�
omenMain:=omen
While .T.
  if !S_IswShad()  ; S_wSetShad([w/n]) ; end
  @ 24,00 say space(80)
  key := S_InKey(0)
  do Case
     case omen == omenMain .and. key == K_ESC
       S_Beep()
       if S_Err({18,28,"�������� ࠡ���?","% ��� ;  �� ; "}) == 2
           omen:close()
           exit
        else
           loop
        end
  End
  omen:work(key,@omen)
End
END SEQUENCE
S_ShowTime()
S_waClose()
DbCloseAll()
S_cls(" ")
quit
return ( Nil )
*================================================================ MainMenu
Static Function MainMenu(data)
Local oPrompt,omenu0,omenu1,omenu2,omenu3,i, omenu22, omenu23, omen4, j

// ���� 0    >>>>>>>>>>>>>>> ������� <<<<<<<<<<<<<<<
omen0:=oMenuNew( 2, 2, .F.     ,;
               {" ���� ",;
                " �������� ",;
                " � � � ",;
                " ��ࢨ� ",;
                " ��x�� "})
oprompt1:=oPromptNew(24,0,80)
oprompt1:Color := {"n/w","n/w"}
omen0:Prompt:=oPrompt1
i := j := 0
omen0:addPrompt(++i,"��孮�����᪨� ����樨 �� ������� ����")
omen0:addPrompt(++i,"��ନ஢���� � ����� �������⥩")
omen0:addPrompt(++i,"������� ����⨢�� �ࠢ�筮� ���ଠ樨 �����")
omen0:addPrompt(++i,"��ࢨ�� ����樨")
omen0:addPrompt(++i,"��室 �� �ணࠬ��")
omen0:block(i,{||Mquit()})
i := 0
// ����     >>>>>>>>>>>>>>> ���� <<<<<<<<<<<<<<<
omen:=oMenuNew()
omen:add("��室")
omen:addPrompt(++i,"���४�஢��/���� ��室�")
omen:block(i,{||VedPrix()})

omen:add("���室 (��室 ���)")
omen:addPrompt(++i,"���४�஢��/���� ��室�")
omen:block(i,{||VedRasx()})

omen:add("���⪨")
omen:addPrompt(++i,"���४�஢��/���� ���⪮�")
omen:block(i,{||VedOst()})

omen:add("����� ���� ")
omen:addPrompt(++i,"����� ���� ���")
omen:block(i,{||VvodData()})

omen:add("�����⨥ �����")
omen:addPrompt(++i,"�����⨥ �����")
omen:block(i,{||CloseMes()})

omen:add("��।�� � �� No 6")
omen:addPrompt(++i,"��।�砯 ������ � 6 ������-�����")
omen:block(i,{||MoveGo6()})

omen:add("����������������������������")
omen:addPrompt(++i,"")
omen:hide := i

omen:add("���⪨ ���.��������. ���")
omen:addPrompt(++i,"���४�஢��/���� ���⪮� ���ਠ�쭮-�⢥��⢥���� ���")
omen:block(i,{||VedOstM()})

omen:add("���室 ���.��������. ���")
omen:addPrompt(++i,"���४�஢��/���� ��室� ���ਠ�쭮-�⢥��⢥���� ���")
omen:block(i,{||VedRasxM()})

omen:add("��������")
omen:addPrompt(++i,"���ᠭ��")
omen:block(i,{||Spisanie() })

omen:Prompt:=oPrompt1
omen0:addSub(++j,omen)

i := 0
// ���� 2    >>>>>>>>>>>>>>> ��ନ஢���� � ����� �������⥩ <<<<<<<<<<<<<<<
omen:=oMenuNew()
omen:add("��������� ��室�")
omen:addPrompt(++i,"��ନ஢���� �������� �� ��室� ���ਠ���")
omen:block(i,{||VedomPrix()})

omen:add("��������� ��室�")
omen:addPrompt(++i,"��ନ஢���� �������� �� ��室� ���ਠ���")
omen:block(i,{||VedomRasx()})

omen:add("����⭠� ���������")
omen:addPrompt(++i,"��ନ஢���� ����⭮� �������� �� �������� ���ਠ���")
omen:block(i,{||VedomObor()})

omen:add("��������������������������������������")
omen:addPrompt(++i,"")
omen:hide := i

omen:add("��������� ��室� ���.��������. ���")
omen:addPrompt(++i,"��ନ஢���� �������� �� ��室� ���ਠ��� ���ਠ�쭮-�⢥��⢥���� ���")
omen:block(i,{||MVedomPrix()})

omen:add("��������� ��室� ���.��������. ���")
omen:addPrompt(++i,"��ନ஢���� �������� �� ��室� ���ਠ��� ���ਠ�쭮-�⢥��⢥���� ���")
omen:block(i,{||MVedomRasx()})

omen:add("����⭠� ��������� ���.��������. ���")
omen:addPrompt(++i,"��ନ஢���� ����⭮� �������� ���ਠ�쭮-�⢥��⢥���� ���")
omen:block(i,{||MVedomObor()})

omen:add("��������� ��� ࠡ�⭨���")
omen:addPrompt(++i,"��ନ஢���� �������� ��� ࠡ�⭨���")
omen:block(i,{||MVedomObo_()})

omen:Prompt:=oPrompt1
omen0:addSub(++j,omen)

i := 0
// ���� 3    >>>>>>>>>>>>>>> � � � <<<<<<<<<<<<<<<
omen:=oMenuNew()
omen:add("��ࠢ�筨� �࣠����権")
omen:addPrompt(++i,"������� �ࠢ�筨�� �࣠����権")
omen:block(i,{||VedEnt_()})

omen:add("��ࠢ�筨� ��⮢")
omen:addPrompt(++i,"������� �ࠢ�筨�� ��⮢")
omen:block(i,{||VedChet_()})

omen:add("��ࠢ�筨� ���ਠ���")
omen:addPrompt(++i,"������� �ࠢ�筨�� ���ਠ���")
omen:block(i,{||VedMat_()})

omen:Prompt:=oPrompt1
omen0:addSub(++j,omen)
i := 0

// ���� 4    >>>>>>>>>>>>>>> ������ <<<<<<<<<<<<<<<
omen:=oMenuNew()

omen:add("����� �� �� ��᪥�� ")
omen:addPrompt(++i,"ᮧ����� ���客�� ����� �� �� ��᪥�")
omen:block(i,{||CopyDb()})

omen:add("������஢���� � ������� �� ")
omen:addPrompt(++i,"������஢���� � ᦠ⨥ ���� ������")
omen:block(i,{||DbPack()})

omen:add("��������")
omen:addPrompt(++i,"��������")
omen:block(i,{ | |S_Calc() })

omen:add("���������")
omen:addPrompt(++i,"���������")
omen:block(i, { |x| x := Set(4,"dd.mm.yy"),;
                          S_Calend(3,50),;
                          Set(4,x) } )
                          
omen:add("������� ����")
omen:addPrompt(++i,"��ᯥ�⪠ �������� ����")
omen:block(i,{ | |PrnDbf() })

omen:add("��ਪ�਩ ���� ��������� �����")
omen:addPrompt(++i,"����ன�� �� ��ਪ�਩ ���� SUPERLIST.DBF")
omen:block(i,{ | |VvodTn() })

omen:add("��ਪ�਩ ���� �� No 6")
omen:addPrompt(++i,"����ன�� �� ��ਪ�਩ ���� �� No 6")
omen:block(i,{ | |VvodDir() })

omen:Prompt:=oPrompt1
omen0:addSub(++j,omen)

return ( oMen0 )
*==================================================================== MQuit
Static Function Mquit()
   __KeyBoard(Chr(K_ESC)+Chr(K_ESC))
Return ( Nil )
/////////////////////////////////////////////////////////////////////////////
Static Function DbPack()
Local ColorOld := SetColor(COLOR_BAZA), aFile := sset[SSET_LEN], i
S_Open_M(10,03,20,30,,sset[2])
for i := 1 to len(aFile)
   if OpenDbf_(sset[SSET_BAZA]+aFile[i],.t.,"Work")
      @ MaxRow()-1,02 say aFile[i]
                               Pack
      @ MaxRow()-1,10 say "Pack"
                              Reindex
      @ MaxRow()-1,15 say "Reindex"
      Scroll(01,01,MaxRow()-1,MaxCol()-1,1)
      Work->(DbCloseArea())
    End
next
My_Char()
@ MaxRow()-1,5 say "������ �������..."
Inkey(0)
S_wCloseSl(S_RanDom()%22+1)
SetColor(ColorOld)
Return ( Nil )
/////////////////////////////////////////////////////////////////////////////
Static function CopyDb()
Local ColorOld := SetColor(COLOR_BAZA), aFile := sset[SSET_LEN], i
S_Err({"��⠢� ��᪥�� � ��᪮��� � ������ �������"})
S_Open_M(10,03,20,30,,sset[2])
@ MaxRow()-1,02 say "���� ��᪥��"
S_FileDel("a:\*.*")
Scroll(01,01,MaxRow()-1,MaxCol()-1,1)
for i := 1 to Len(aFile)
    if OpenDbf_(sset[SSET_BAZA]+aFile[i],.t.,"Work")
      @ MaxRow()-1,02 say aFile[i]+" ---> �������"
      copy to ("a:\"+aFile[i])
      @ MaxRow()-1,23 say "Ok!"
      Scroll(01,01,MaxRow()-1,MaxCol()-1,1)
      Work->(DbCloseArea())
    End
next
My_Char()
@ MaxRow()-1,5 say "������ �������..."
Inkey(0)
S_wCloseSl(S_RanDom()%22+1)
SetColor(ColorOld)
Return ( Nil )
/////////////////////////////////////////////////////////////////////////////
static Function VvodData()      //  ���� ���� � ���
Local dData := date(),;
      ColorOld := SetColor(sset[32]+","+sset[2]),;
      GetList := {}, WindowOld := S_wSelect()

if File(sset[SSET_BAZA]+"Data.!!!")
     dData := ctod(S_ArRest(sset[SSET_BAZA]+"Data.!!!")[1])
End
S_Open_M(12,38,14,65,sset[32],sset[2])
@ 01,01 say "������ ����" get dData Pict "@d" valid !empty(dData)
read
S_wCloseSl(S_RanDom()%22+1)
S_ArSave({dtoc(dData)},sset[SSET_BAZA]+"Data.!!!")
SetColor("n/w")
S_wSelect(0)
@ 23,00 say padc( {"����ᥭ�","�������쭨�","��୨�","�।�","��⢥�",;
          "��⭨�","�㡡��"}[dow(ddata)]+" "+str(day(ddata),2)+" "+;
          S_cMonth(dData,.t.)+" "+str(year(ddata),4)+" ����",80)
S_wSelect(WindowOld)
sset[SSET_DATA] := dData
SetColor(ColorOld)
return ( Nil )
///////////////////////////////////////////////////////////////////////////
static Function VvodDir()      //  ���� ��ਪ��� 
Local cDir := padr(sset[SSET_DIR6],30),;
      ColorOld := SetColor(sset[32]+","+sset[2]),;
      GetList := {}, cursorOld := SetCursor(1)

S_Open_M(12,15,14,65,sset[32],sset[2])
@ 01,01 say "������ ���-਩" get cDir
read
S_wCloseSl(S_RanDom()%22+1)
sset[SSET_DIR6] := alltrim(cDir)
S_ArSave({sset[SSET_DIR6],sset[SSET_DIRTN]},sset[SSET_BAZA]+"DirGo6.!!!")
SetColor(ColorOld)
SetCursor(CursorOld)
return ( Nil )
///////////////////////////////////////////////////////////////////////////
static Function VvodTN()      //  ���� ��ਪ��� 
Local cDir := padr(sset[SSET_DIRTN],30),;
      ColorOld := SetColor(sset[32]+","+sset[2]),;
      GetList := {}, cursorOld := SetCursor(1)

S_Open_M(12,15,14,65,sset[32],sset[2])
@ 01,01 say "������ ���-਩" get cDir
read
S_wCloseSl(S_RanDom()%22+1)
sset[SSET_DIRTN] := alltrim(cDir)
S_ArSave({sset[SSET_DIR6],sset[SSET_DIRTN]},sset[SSET_BAZA]+"DirGo6.!!!")
SetColor(ColorOld)
SetCursor(CursorOld)
return ( Nil )
///////////////////////////////////////////////////////////////////////////
Static Function M_Error(e)
local i, cMessage, aOptions := {}, nChoice
if  e:genCode == 5  ;  return (0)  ; end
if ( e:genCode == 21 .and. e:osCode == 2  .and. e:SubCode == 1003 .and. ;
               Valtype("INDNAME") == "C" )                       // ������
     if ( i := LastRec()+1 ) > 2
       e:cargo := 0
       cMessage := [" ����... �o������� ������ ]+e:FileName+[ "]
       S_Line_N(18,04,65,i,1)
       @ 00,(MaxCol()-len(cMessage))/2 say cMessage
       DbCreateIndex( (e:FileName),IndName, { | | S_Line_N(18,04,65,i,++e:cargo), &(IndName) } )
       S_Line_N()
     else
       DbCreateIndex( (e:FileName),IndName, { | |  &(IndName) }  )
     end
     NetErr( .t. )  ;  return ( .f. )
end
if  e:genCode == 21 .and. e:osCode == 3  .and. e:SubCode == 1001 // �����
  cMessage := S_GetDrive(e:FileName)+S_GetPath(e:FileName)
  S_Sys({"@��������"," ","^��������� ����� "+cMessage,;
         "� 䠩��",e:FileName," ","��� �த������� ������ ���� �������"," "})
  inkey(0)
  S_Sys()
  break .f.
end
if ( e:genCode == 21 .and. e:osCode == 32 .and. e:canDefault )         // ����
   NetErr( .t. )    ;   return ( .f. )
end
if ( e:genCode == 40 .and. e:canDefault )
   NetErr(.t.)
   return (.f.)
end
cMessage := if( e:severity > 1, " �訡�� ", " �।�०����� " )
cMessage += iif(ValType(e:subsystem) == "C",e:subsystem(),"???")
cMessage += [/]+iif(ValType(e:subCode) =="N",ltrim(str(e:subCode)),"???")
cMessage += iif(ValType(e:description) == "C","  "+e:description,"" )
if ( !Empty(e:filename) )
   cMessage += (": " + e:filename)
elseif ( !Empty(e:operation) )
   cMessage += (": " + e:operation)
end
aOptions := {"�����஢���","��������"}
if (e:canRetry)   ;   AAdd(aOptions, "�������")  ;  end
if (e:canDefault) ;   AAdd(aOptions, "�⠭���⭮") ;  end
nChoice := 0
While ( nChoice == 0 )
   if ( Empty(e:osCode) )
      nChoice := Alert( cMessage, aOptions )
     else
      nChoice := Alert( cMessage + "(DOS �訡�� "+ltrim(str(e:osCode))+")", ;
                     aOptions )
   end
   if ( nChoice == NIL ) ; exit ;  end
end
if ( !Empty(nChoice) )
   if ( aOptions[nChoice] == "�����஢���" )
      Break(e)
   elseif ( aOptions[nChoice] == "�������" )
      return (.t.)
   elseif ( aOptions[nChoice] == "�⠭���⭮" )
      return (.f.)
   end
end
S_wAclose()
S_wSelect(0)
if ( !Empty(e:osCode) )
     cMessage += " (DOS �訡�� " + ltrim(str(e:osCode)) + ") "
end
? cMessage
i := 2
While ( !Empty(ProcName(i)) )
   ? "���� �� ", Trim(ProcName(i)) + "(" + ltrim(str(ProcLine(i))) + ")  "
   i++
end
ErrorLevel(1)  ;  DbClearInd()
DbCommitAll()  ;  DbCloseAll()
__quit()
////////////////////////////////////////////////////////////////////////
function My_Sound()
Local Sound := {{300,2},{100,2},{300,2},{100,2},{300,2},{100,2},;
                {300,2},{100,2},{300,2},{100,2},{300,2},{100,2} }
aeval(Sound,{ |x| tone(x[1], x[2])  } )
Return Nil
////////////////////////////////////////////////////////////////////////
Function My_Mon()
aeval({ {196,2},{196,2},{196,2},{220,2},{196,4},{164,4}  },;
      { |x| tone(x[1], x[2])  } )
return ( Nil )
////////////////////////////////////////////////////////////////////////
Function My_First()
aeval({ {392,2},{392,2},{392,2},{311,5},{15,12},{349,2},;
        {349,2},{293,5} },{ |x| tone(x[1], x[2])  } )
Return ( Nil )
////////////////////////////////////////////////////////////////////////
Function ShowPrn(File, Name, Line, lEx, nKol)
Local lPrint := .f.,      ;   //|______ ����訢��� ������⢮ ��������஢
      nSaveSetPrn
IF lEx==NIL
   lEx:= .F.
ENDIF
if File(File) .and. S_Err({"^�뢥�� ","^"+Name,"�� ��࠭?","% ��� ; �� ;"})==2
   lPrint := LookFile(File,Line)
end
if !lPrint .and. File(File) .and. ;
   S_Err({"^�뢥��","^"+Name,"�� �����?","% �� ; ��� ;"})==1
   IF lEx
      if N_GetKol(@nKol)==K_ESC.OR.;
         empty(nKol)
         // �����稢���
         RETURN (NIL)
      end
      nSaveSetPrn:= SSET[SETPRINTER]
      SSET[SETPRINTER]:= .T.
      FOR i=1 TO nKol
         M_Tprn(File,.f.,1)
      NEXT
      SSET[SETPRINTER]:= nSaveSetPrn
   ELSE
      M_Tprn(File,.f.,1)
   ENDIF
end
Return ( Nil )
////////////////////////////////////////////////////////////////////////
Function M_Tprn(File)
MemVar Sset
Local Obj := oFileNew(File,0), Size, nPrint := 0, cLine,;
      CurList := 1, i, BlockList := { | | .t. },;
      ColorOld := SetColor(),;
      ListList := "", ListNac := ListKon := 0,;
      HelpOld := sset[113]
BEGIN SEQUENCE
sset[113] := "M_TPRN"
if ( i := S_Err({05,03,"^������","०�� ���� �� ���⠬",;
     "% ����� ; �������� ; ���᮪ ;"}) ) == 2
   S_Open_m(03,03,07,28,Sset[77],sset[77])
   SetColor(Sset[76]+","+sset[77]+",,,"+sset[76])
   @ 01,02 say "��砫�� ����: " get ListNac pict "999999" valid ListNac > 0
   @ 02,02 say "������ ����:  " get ListKon pict "999999" valid ListKon>=ListNac
   read
   BlockList := { |x| x>=ListNac .and. x<=ListKon }
   S_wCloseSl(S_RanDom()%22+1)
   SetColor(ColorOld)
elseif i == 3
   S_Open_M(03,03,18,16,Sset[77],Sset[77])
   SetColor(Sset[76]+","+sset[77]+",,,"+sset[76])
   @ MaxRow()-4,01 say "�����-"
   @ MaxRow()-3,01 say " �   "
   @ MaxRow()-2,01 say "����� "
   @ MaxRow()-1,01 say "���� ->"
   While ( .t. )
      Scroll(01,09,MaxRow()-1,MaxCol()-1,1)
      ListNac := 0
      @ MaxRow()-1,09 get ListNac pict "999999" valid ListNac > 0
      read
      if LastKey() == 27 ; exit ; end
      ListList += str(ListNac,6)+"^"
   end
   S_wCloseSl(S_RanDom()%22+1)
   BlockList := { |x| str(x,6)+"^"$ListList }
   SetColor(ColorOld)
end
Obj:Open()
Size := Obj:Len()
obj:Seek(0,0)
S_Line_N(16,3,65,Size,1)
@ 01,06 say "��������..."
@ 01,40 say "������ �� ������ � �㬠���"
cLine := [" �� ����砭�� �㤥� ����� ��㪮��� ᨣ��� "]
@ 00,(MaxCol()-len(cLine))/2 say cLine
While ( !Obj:eof() .and. nPrint == 0 )
  cLine := obj:ReadLn(256) ;  cLine := left(cLine,Len(cLine)-1)
  S_Line_N(16,3,65,Size,Obj:Tell())
  if ( i := S_AtNum("����#",cLine) ) # 0
      CurList := val(substr(cLine,i+6,6))
  end
  if eval(BlockList,CurList)
    nPrint := S_Sprn(cLine+chr(13)+chr(10),,.t.)
  end
end
My_Sound()
S_Line_N()
END SEQUENCE
obj:close()
sset[113] := HelpOld
Return ( .t. )
////////////////////////////////////////////////////////////////////////
Function LookFile(cFile,Line)
Local lPrint := .f., bNil := {||.t.},;
      CodHelpOld := Sset[113],;
      aSaveKey := { {K_F2, S_SetKey(K_F2, {||lPrint:=M_Tprn(cFile)},"�����")},;
                    {K_F3, S_SetKey(K_F3,bNil,"      ")},;
                    {K_F4, S_SetKey(K_F4,bNil,"      ")},;
                    {K_F5, S_SetKey(K_F5,bNil,"      ")},;
                    {K_F6, S_SetKey(K_F6,bNil,"      ")},;
                    {K_F7, S_SetKey(K_F7,bNil,"      ")},;
                    {K_F8, S_SetKey(K_F8,bNil,"      ")},;
                    {K_F9, S_SetKey(K_F9,bNil,"      ")},;
                    {K_F10, S_SetKey(K_F10,bNil,"��室 ")} },;
     i
BEGIN SEQUENCE
Sset[113] := "S_LVEW"
Line := if(Line==Nil .or. ValType(Line)#"N" .or. Line > 78,78,Line)
S_Lview(cFile,01,01,22,Line+1)
For i := 1 to len(aSaveKey)
  if !( ValType(aSaveKey[i])=="U" )
      S_SetKey(aSaveKey[i][1],aSaveKey[i][2][1],aSaveKey[i][2][2])
  end
next
END SEQUENCE
Sset[113] := CodHelpOld
Return ( lPrint )
////////////////////////////////////////////////////////////////////////
FUNC N_GetKol(nKol, cString)
MEMVAR sset
LOCAL cSaveCurs:= SetCursor(iif(readInsert(), SC_INSERT, SC_NORMAL)),;
      cSaveColor := SetColor(sset[AT_S_H]+","+        ;
                             sset[AT_BR_N]+",,,"+     ;
                             sset[AT_S_H]),           ;
      GetList:= {},       ;
      nKey,               ;
      nWin,               ;
      nTop   := 10,       ;
      nLeft  := 20,       ;
      nBottom:= 15,       ;
      nRight := 59

nWin:= S_Open_M(nTop,nLeft,nBottom,nRight,,sset[AT_BR_N])

SetCursor( IF(ReadInsert(), SC_INSERT, SC_NORMAL) )

// ����訢��� ������⢮ �������.
IF !valType(nKol)=="N"
   nKol:= 0
ENDIF
@ 02, 03 say "������ ������⢮ ��������஢:"
IF !empty(cString).AND.valType(cString)=="C"
   @ 02, 35 get nKol picture "99"  ;
            when myStatus(cString) ;
            valid !empty(nKol)
ELSE
   @ 02, 35 get nKol picture "99" valid !empty(nKol)
ENDIF
read
nKey:= LastKey()

// ����뢠�� ����
s_wSelect(nWin) ; s_wCloseSl(S_RanDom()%22+1)
// ����⠭�������� �����
SetCursor(cSaveCurs)
// ����
SetColor(cSaveColor)
RETURN (nKey)
////////////////////////////////////////////////////////////////////////
FUNC myStatus(cStr)
MEMVAR sset
IF !(valType(cStr)=="C")
   cStr:= " "
ENDIF
@ MaxRow()-1, 1 SAY padc(cStr,MaxCol()-1) COLOR sset[AT_S_FR_T]
RETURN(.T.)
////////////////////////////////////////////////////////////////////////////
Function OpenDbf_(cDataBase,Status,cAlias,nSeconds,lPrint)
Local nRecno, nLastRec, i, nPos, cDir := "", aFile := {}
Private cMessage, iFile

aadd(aFile,      {{"S_ENT","========= ��ࠢ�筨� �࣠����権 ============="},;
                  {{"S_ENT","str(Ent,4)",.f.}},;
                  { {"Ent",  "N",04,00," ��� �࣠����樨    "},;
                    {"Naim", "C",35,00," ������������       "},;
                    {"Okpo", "C",11,00," ��� ����           "},;
                    {"Mfo",  "C",09,00," ���                "},;
                    {"Schet","C",12,00," ���               "},;
                    {"Bank", "C",35,00," ������������ ����� "}}})
aadd(aFile,       {{"S_CHET","========= ��ࠢ�筨� ��⮢ ==============="},;
                   {{"S_CHET","str(Chet,5,2)",.f.}},;
                   { {"Chet",  "N",05,02," ��� ���         "},;
                     {"Naim",  "C",30,00," ������������      "}}})
aadd(aFile,       {{"S_MAT","========= ��ࠢ�筨� ���ਠ��� ==========="},;
                   {{"S_MAT","str(K_Mat,5,0)",.f.}},;
                   { {"K_Mat", "N",05,00," ��� ���ࠫ� "},;
                     {"Naim",  "C",25,00," ������������ "},;
                     {"EdIzm", "C",04,00," ��. ���.     "},;
                     {"Cena",  "N",11,02," ���� ���ᨬ��쭠�"},;
                     {"SrNos", "N",05,02," �ப ��᪨   "},;
                     {"Pr",    "N",01,00," �ਧ���      "},;
                     {"KSchet","N",05,02," �।�� ��� "}}})
aadd(aFile,      {{"PRIXOD","========= ��室  ============="},;
                  {{"PRIXOD","str(KSchet,5,2)+str(Ent,4)+str(K_Mat,5)",.f.}},;
                  { {"Ent",   "N",04,00," ��� �࣠����樨    "},;
                    {"K_Mat", "N",05,00," ��� ���ਠ��      "},;
                    {"NNak",  "N",06,00," N ���������        "},;
                    {"KSchet","N",05,02," �।�� ���       "},;
                    {"Kol",   "N",09,03," ������⢮         "},;
                    {"Sum",   "N",11,02," �㬬�              "}}})
aadd(aFile,      {{"RASXOD","========= ���室  ============="},;
                  {{"RASXOD","str(KSchet,5,2)+str(K_Mat,5)",.f.},;
                   {"RASXTN","Ksp+TabN+str(KSchet,5,2)+str(K_Mat,5)",.f.}},;
                  { {"K_Mat",  "N",05,00," ��� ���ਠ��    "},;
                    {"DSchet", "N",05,02," ����� ���      "},;
                    {"NNak",  "N",06,00," N ���������        "},;
                    {"KSchet","N",05,02," �।�� ���       "},;
                    {"Kol",   "N",09,03," ������⢮         "},;
                    {"Sum",   "N",11,02," �㬬�              "},;
                    {"TabN",  "C",06,00," ������� �����    "},;
                    {"DataP", "D",08,00," ��� ����祭��     "},;
                    {"Ksp",   "C",04,00," ���ࠧ�������      "}}})
aadd(aFile,      {{"OSTMAT","========= ���⪨  ============="},;
                  {{"OSTMAT","str(KSchet,5,2)+str(K_Mat,5)",.f.}},;
                  { {"K_Mat", "N",05,00," ��� ���ਠ��      "},;
                    {"KSchet","N",05,02," �।�� ���       "},;
                    {"Kol",   "N",09,03," ������⢮         "},;
                    {"Sum",   "N",11,02," �㬬�              "}}})
aadd(aFile,      {{"BAZA","========= GO6  ============="},;
                  {{"BAZA","str(Ent,4)+str(chet,5,2)",.f.}},;
                  { {"Ent",  "N",04,00," �࣠������    "},;
                    {"Chet", "N",05,02," ���          "},;
                    {"Summa","N",13,02," �㬬�          "}}})
aadd(aFile,      {{"AKT","========= ��室  ��� ============="},;
                  {{"AKT","Ksp+TabN+str(Schet,5,2)+str(KSchet,5,2)+TabN+str(K_Mat,5)",.f.}},;
                  { {"TabN",  "C",06,00," ⠡���� �����    "},;
                    {"Ksp",   "C",04,00," ���ࠧ�������      "},;
                    {"K_Mat", "N",05,00," ��� ���ਠ��      "},;
                    {"NNak",  "N",06,00," N ���������        "},;
                    {"KSchet","N",05,02," �।�� ���       "},;
                    {"Schet", "N",05,02," ���               "},;
                    {"Kol",   "N",09,03," ������⢮         "},;
                    {"Sum",   "N",11,02," �㬬�              "}}})
aadd(aFile,      {{"OSTMATM","========= ���⪨ ��� =========="},;
                  {{"OSTMATM","Ksp+TabN+str(KSchet,5,2)+str(K_Mat,5)",.f.}},;
                  { {"TabN",  "C",06,00," ������� �����    "},;
                    {"Ksp",   "C",04,00," ���ࠧ�������      "},;
                    {"DataP", "D",08,00," ��� ����祭��     "},;
                    {"K_Mat", "N",05,00," ��� ���ਠ��      "},;
                    {"KSchet","N",05,02," �।�� ���       "},;
                    {"Kol",   "N",09,03," ������⢮         "},;
                    {"Sum",   "N",11,02," �㬬�              "}}})
                        
if lPrint <> Nil
  cFile := cDatabase
  if ( nPos := ascan(aFile,{|x| x[1][1]==Upper(cFile)}) ) == 0 ; return ( Nil ) ; End
  Set(20,"PRINT")
  @ prow()+1,00 say "������� 䠩��: "+cFile+" "+aFile[nPos][1][2]
  @ prow()+1,00 say "-----------------------------------------------------"
  @ prow()+1,00 say " ������.|���|�����|���| ������������               "
  @ prow()+1,00 say "-----------------------------------------------------"
  for i := 1 to len(aFile[nPos][3])
      @ prow()+1,00 say aFile[nPos][3][i][1]
      @ prow(),10 say aFile[nPos][3][i][2]
      @ prow(),15 say aFile[nPos][3][i][3] pict "99"
      @ prow(),20 say aFile[nPos][3][i][4] pict "99"
      @ prow(),25 say aFile[nPos][3][i][5]
  next
  @ prow()+1,00 say "-----------------------------------------------------"
  @ prow()+1,00 say "           ����:                                     "
  for i := 1 to Len(aFile[nPos][2])
     @ prow()+1,01 say aFile[nPos][2][i][1]+" --------> "+aFile[nPos][2][i][2]
  Next
  @ prow()+1,00 say "  "
  @ prow()+1,00 say "  "
  @ prow()+1,00 say "  "
  @ prow()+1,00 say ""
  Set(20,"SCREEN")
  Return ( Nil )
End 
if cDatabase == Nil .or. empty(cDatabase) ;  return ( .f.)  ;   end
cDir  := S_GetDrive(cDatabase)+S_GetPath(cDatabase)
cFile := S_GetName(cDatabase)
if ( nPos := ascan(aFile,{|x| x[1][1]==Upper(cFile)}) ) == 0 ; return ( .f. ) ; End
if !File(cDir+cFile+".Dbf")
  fErase(cDir+cFile+NTXCDX)
  Select 0
  DbCreate(cDir+cFile+".Dbf",aFile[nPos][3])
  Use
End
cAlias := if(cAlias==Nil,cFile,cAlias)
Status:= if(status==Nil,.t.,Status) //////////////////// F
nSeconds:= if(nSeconds==Nil,20,nSeconds)
if !M_Use(cDir+cFile,Status,cAlias,nSeconds) ; Return ( .f. ) ; end

for i := 1 to Len(aFile[nPos][2])
  iFile := cDir+aFile[nPos][2][i][1]
  if !File(iFile+NTXCDX)
     if ( nLastRec := (cAlias)->(LastRec())+1 ) > 2
       nRecno := 0
       cMessage := [" ����... �o������� ������ ]+iFile+NTXCDX+[ "]
       S_Line_N(18,04,65,nLastRec,1)
       @ 00,(MaxCol()-len(cMessage))/2 say cMessage
       cMessage := aFile[nPos][2][i][2]
       DbCreateIndex( (iFile+NTXCDX),cMessage,;
                      {|| S_Line_N(18,04,65,nLastRec,++nRecno),;
                      &(cMessage) },;
                      aFile[nPos][2][i][3] )
       S_Line_N()
     else
       cMessage := aFile[nPos][2][i][2]
       DbCreateIndex( (iFile+NTXCDX),cMessage,;
                                  {|| &(cMessage) },;
                                  aFile[nPos][2][i][3] )
     end
  End
Next
(cAlias)->(DbClearIndex())
for i := 1 to Len(aFile[nPos][2])
  iFile := cDir+aFile[nPos][2][i][1]
  (cAlias)->(DbSetIndex( (iFile) ))
next
(cAlias)->(DbSetOrder(1))
Return ( .t. )
///////////////////////////////////////////////////////
Function  M_Use(cDatabase,lOpenMode,cAlias,nSeconds,cVia)
MemVar Sset
local lForever, nPos := 0, cFile, lRet := .t., i

if cDatabase == Nil .or. empty(cDatabase) ; return ( .f. ) ; end
cFile := S_GetDrive(cDatabase)+S_GetPath(cDatabase)
cVia  := if(cVia == Nil ,"DBFNTX",cVia)
if !S_isPath(cFile) // ��������� �����
     S_Err({"��������� ����� � ����",cDataBase," "})
     Return ( .f. )
end
BEGIN SEQUENCE
   nSeconds := iif(nSeconds == Nil,20,nSeconds)
   lOpenMode := iif(lOpenMode == Nil,.f.,lOpenMode)
   cAlias := iif(cAlias == Nil,S_GetName(cDataBase),cAlias)
   lForever := (nSeconds == 0)
   Select 0
   While ( lForever .or. nSeconds > 0 )
    if lOpenMode
          use (cDatabase) exclusive  alias (cAlias)
      else
          use (cDatabase) shared  alias (calias)
     end
     if !Neterr()
       if nPos > 1 ; S_Sys() ; end
       lRet := .t.
       break
     end
     if ++nPos == 2
       S_Sys({"@����⪠ ������ 䠩��",;
              "����... "+cDataBase+" ������㯥�",;
              "��� �⪠�� �� ����� ������ ESC"})
     end
     if inkey(1) == K_ESC
        if nPos > 1  ; S_Sys() ; end
        S_Err({"@�������� !!!","���뢠��� ����樨","�� ��襩 ���樠⨢�"})
        lRet := .f.
        break
     end
     nSeconds -= 1
   end
   if nPos > 1  ; S_Sys() ; end
   S_Err({"@�������� !!!","�६� �������� ��⥪��","���뢠��� ����樨"})
   lRet := .f.
END SEQUENCE
return ( lRet )
/////////////////////////////////////////////////////////////////
Function fOption()
Local cMessage
if Bof()
   cMessage := [" ����... �o������� ⥣ ]+Sx_I_TagName()+[ � 䠩�� ]+;
               cFile+Sx_I_IndexName()+[ "]
   S_Line_N(18,04,65,LastRec(),1)
   @ 00,(MaxCol()-len(cMessage))/2 say cMessage
elseif eof()
   S_Line_N()
   S_Beep()
else
   S_Line_N(18,04,65,LastRec(),Recno())
end
Return ( Nil )
///////////////////////////////////////////////////////////////////
Static Function PrnDbf()
Local cName := space(10), cDir := padr(sset[SSET_BAZA],30)

S_Open_M(10,03,12,17,,sset[2])
While .t.
  @ 01,01 say padc(" ",MaxCol()-1)
  @ 01,01 get cName color sset[2]+","+sset[1]
  read
  if LastKey()==K_ESC ; Exit ; End
  @ 01,01 say padc("������..",MaxCol()-1)
  OpenDbf_(alltrim(cName),,,,999)
  Set(20,"SCREEN")
End
Set(20,"SCREEN")
S_wCloseSl(S_RanDom()%22+1)
Return ( Nil )
//////////////////////////////////////////////////////////////////
FUNCTION IsUsed(cAlias)
LOCAL nSaveSel:= Select(), ;
      lRet:= .F.,          ;
      i:= 1
DO WHILE (!lRet.AND.i<255)
   SELECT (i++)
   IF !empty(cAlias) .AND. valType(cAlias)=="C"
      // �஢�ઠ �� ����稥 �����
      lRet:= upper(cAlias)==alias()
   ELSE
      // �஢�ઠ �� ����稥 ����⮩ ࠡ�祩 ������
      lRet:= used()
   ENDIF
ENDDO
SELECT (nSaveSel)
RETURN( lRet )
/////////////////////////////////////////////////////////////
FUNCTION S_IsDir(cPath)
LOCAL cSavePath := S_FullPath(S_EXENAME()),  ;
      cSaveDisk := S_GETDRIVE(S_EXENAME()),  ;
      cDisk,                                 ;
      lChDisk,                               ;
      lChDir,                                ;
      lRet:= .T.
// ����騩 ��४�਩ �ᥣ�� �������!
IF !(cPath=="")
   cDisk:= S_GETDRIVE(cPath)
   lChDisk:= !(upper(cDisk)==upper(cSaveDisk))
   IF !empty(cDisk).AND.lChDisk
      IF !S_CHDISK(cDisk)
         RETURN (lRet:= .F.)
      ENDIF
   ENDIF
   // �᫨ ���� �� ����...
   IF (lChDir:= !empty(S_GETDIR(cPath+"\nul")))
      // �஢�ਬ ���
      lRet:= (S_CHDIR(cPath) == 0)
   ENDIF
   IF !empty(cDisk).AND.lChDisk
      S_CHDISK(cSaveDisk)
   ENDIF
   IF lChDir
      S_CHDIR(cSavePath)
   ENDIF
ENDIF
RETURN(lRet)
///////////////////////////////////////////////////////////////////////////
FUNCTION S_FullPath(cFullFile)
LOCAL cPath:= S_GETPATH(cFullFile),   ;
      nLen
nLen:=len(cPath)
cPath:= S_GETDRIVE(cFullFile)+;
            iif( empty(cPath), cPath,;
                  substr(cPath, 1, nLen-1))
RETURN(cPath)
//////////////////////////////////////////////////////////////////////////
FUNC S_isPath(cPath)
IF !empty(cPath)
   cPath:= S_GETDRIVE(cPath+"nul")+S_GETDIR(cPath+"nul")
ENDIF
RETURN(S_IsDir(cPath))
//////////////////////////////////////////////////////////////////////////
FUNCTION S_GETNAME(cFileName)
LOCAL nDrive, nPath, nName, nExt, nLen
C_FILENAME(cFileName, @nDrive, @nPath, @nName, @nExt, @nLen)
RETURN SUBSTR(cFileName, nName, nExt - nName - 1)
/////////////////////////////////////////////////////////////////////////
FUNCTION S_GETDRIVE(cFileName)
LOCAL nDrive, nPath, nName, nExt, nLen
C_FILENAME(cFileName, @nDrive, @nPath, @nName, @nExt, @nLen)
RETURN SUBSTR(cFileName, nDrive, nPath - nDrive)
/////////////////////////////////////////////////////////////////////////
FUNCTION S_GETPATH(cFileName)
LOCAL nDrive, nPath, nName, nExt, nLen
C_FILENAME(cFileName, @nDrive, @nPath, @nName, @nExt, @nLen)
RETURN SUBSTR(cFileName, nPath, nName - nPath)
////////////////////////////////////////////////////////////////////////
FUNCTION S_GETDIR(cFileName)
LOCAL nDrive, nPath, nName, nExt, nLen
C_FILENAME(cFileName, @nDrive, @nPath, @nName, @nExt, @nLen)
RETURN SUBSTR(cFileName, nPath, nName - nPath-1)
/////////////////////////////////////////////////////////////////////////
FUNCTION S_GETEXT(cFileName)
LOCAL nDrive, nPath, nName, nExt, nLen
C_FILENAME(cFileName, @nDrive, @nPath, @nName, @nExt, @nLen)
RETURN SUBSTR(cFileName, nExt, nLen - nExt)
/////////////////////////////////////////////////////////////////////////
Function M_RLock( nSeconds,Alias )
MemVar Sset
local lForever
nSeconds := iif(nSeconds==Nil,20,nSeconds)
Alias := iif(Alias==Nil,Alias(),Alias)
lForever := (nSeconds == 0)
if (Alias)->(Rlock()) ;  return (.t.) ; end
S_Sys({"����⪠ �����஢�� �����",;
       "���� ������ 䠩�� "+alias()+" �����஢���",;
       "��� �⪠�� �� ����� ������ ESC"})
BEGIN SEQUENCE
While ( lForever .or. nSeconds > 0 )
   if inkey(.5) == K_ESC
     S_Sys()
     S_Err({"@�������� !!!","���뢠��� ����樨","�� ��襩 ���樠⨢�"})
     lret := .f.
     break
   end
   nSeconds -= 0.5
   if (Alias)->(Rlock())
      S_Sys() ; lRet := .t.
      break
   end
end
S_Sys()
S_Err({"@�������� !!!","�६� �������� ��⥪��","���뢠��� ����樨"})
lRet := .f.
END SEQUENCE
return ( lRet )
///////////////////////////////////////////////////////////////////////
func M_Append(nWaitSeconds,Alias)
MemVar Sset
local lForever, lRet := .t.
nWaitSeconds := iif(nWaitSeconds==Nil,20,nWaitSeconds)
Alias := iif(Alias==Nil,Alias(),Alias)
lForever := (nWaitSeconds == 0)
BEGIN SEQUENCE
   (Alias)->(DbAppend())
   if !Neterr()  ; break ; end
   S_Sys({"���� ������ ������㯭� ��� ࠡ���",;
          "� ��� �/��� ���ᥭ�� � ��� ���������",;
          "��� ���뢠��� ����樨 ������ ESC"})
   While ( lForever .or. nWaitSeconds > 0 )
     (Alias)->(DbAppend())
     if !Neterr()  ; S_Sys() ; break ;  end
     if inkey(.5) == K_ESC
        S_Sys()
        S_Err({"@�������� !!!","���뢠��� ����樨","�� ��襩 ���樠⨢�"})
        lRet := .f.
        break
      end
     nWaitSeconds -= 0.5
   end
   S_Sys()
   S_Err({"@��������!","�६� �������� ��⥪��","���뢠��� ����樨"})
   lRet := .f.
END SEQUENCE
return ( lRet )
//////////////////////////////////////////////////////////////////////////////
Static Function VedEnt_()
if OpenDbf_(sset[SSET_BAZA]+"S_Ent") 
  VedEnt()
End
DbCloseAll()
Return ( Nil )
//////////////////////////////////////////////////////////////////////////////
Static Function VedChet_()
if OpenDbf_(sset[SSET_BAZA]+"S_Chet") ;  VedChet() ; End
DbCloseAll()
Return ( Nil )
/////////////////////////////////////////////////////////////////////////////
Static Function VedMat_()
if OpenDbf_(sset[SSET_BAZA]+"S_Mat") .and. OpenDbf_(sset[SSET_BAZA]+"S_Chet")
  VedMat()
End
DbCloseAll()
Return ( Nil )
/////////////////////////////////////////////////////////////////////////////
Static function MoveGO6()
Local nRecno, nEnt, nKSchet, nSumma, nLastRec

BEGIN SEQUENCE
if !File(sset[SSET_DIR6]+"Baza.dbf")
  S_Err({" ��������� ���� �� N 6"})
  break
End
if !OpenDbf_(sset[SSET_DIR6]+"Baza",.t.) ; break ; End
if !OpenDbf_(sset[SSET_BAZA]+"Prixod",.t.) ; break ; End
nLastRec := Prixod->(LastRec())
S_Line_N(18,04,65,nLastRec,1)
@ 01,06 say "�������..."
@ 01,42 say "��७��� ����� "
nRecno := "[ �� ����砭�� �㤥� ����� ��㪮��� ᨣ��� ]"
@ 00,(MaxCol()-len(nRecno))/2 say nRecno
nRecno := 0
Prixod->(DbGoTop())
While !Prixod->(eof())
  nKSchet := Prixod->KSchet
  nEnt    := Prixod->Ent
  nSumma  := 0
  While nEnt == Prixod->Ent .and. nKSchet == Prixod->KSchet .and. !Prixod->(eof())
     nSumma += Prixod->Sum
     S_Line_N(18,04,65,nLastRec,++nRecno)
     Prixod->(Dbskip(1))
  End
  if !Baza->(DbSeek(str(nEnt,4)+str(nKSchet,5,2)))
      Baza->(DbAppend())
      Baza->Ent  := nEnt
      Baza->Chet := nKSchet
  End
  Baza->Summa := nSumma
End
S_Line_N()
S_Beep()
END SEQUENCE
DbCloseAll()
Return ( Nil )
//////////////////////////////////////////////////////////////////////////
Function OpenTn()
use (sset[SSET_DIRTN]+"Superlis") new alias Tn via "DBFNTX"
if !file(sset[SSET_DIRTN]+"SuperPon.Ntx")
  index on Ksp+Tn to (sset[SSET_DIRTN]+"SuperPon.Ntx")
End
if !file(sset[SSET_DIRTN]+"SuperTn.Ntx")
  index on Tn to (sset[SSET_DIRTN]+"SuperTn.Ntx")
End
set index to (sset[SSET_DIRTN]+"SuperTn.Ntx"),;
             (sset[SSET_DIRTN]+"SuperPon.Ntx")
return ( Nil )
///////////////////////////////////////////////////////////////////////////
Function OpenKsp()
use (sset[SSET_DIRTN]+"Ssp") new alias ssp via "DBFNTX"
if !file(sset[SSET_DIRTN]+"Ssp.Ntx")
  index on Ksp to (sset[SSET_DIRTN]+"Ssp.Ntx")
End
set index to (sset[SSET_DIRTN]+"Ssp.Ntx")
return ( Nil )
///////////////////////////////////////////////////////////////////////////
