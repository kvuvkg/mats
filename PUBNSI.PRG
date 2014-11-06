#Define COLOR_NSI sset[51]+","+sset[57]+",,,"+sset[51]
#Define COLOR_BAZA sset[32]+","+sset[2]+",,,"+sset[32]
#include "Inkey.ch"
/////////////////////////////////////////////////////////////////////////////
Function VedEnt(nKod,Row,Col)
Local tb, ColorOld, SelectOld := Select(), SursorOld,nKey, nRow, GetList := {},;
      nDelete := 0
if nKod <> Nil .and. S_Ent->(DbSeek(Str(nKod,4)))
   @ Row,Col say left(S_Ent->Naim,30)
   Return ( .t. )
End
ColorOld := SetColor(COLOR_NSI)
SursorOld := SetCursor(0)
DbSelectArea("S_ENT")
S_Open_M(02,33,22,74,,sset[2])
@ 01,01 say "Код  Наименование организации"
@ 02,01 say Repl([─],MaxCol()-1)
@ MaxRow()-2,01 say Repl([─],MaxCol()-1)
@ MaxRow()-1,01 say padc("2печ 3уд 4рег 5корр 6поиск 7поиск 9режим",MaxCol()-1) color sset[5]
tb := TBrowseDb(03,01,MaxRow()-3,MaxCol()-1)
tb:AddColumn(TbColumnNew("" ,{|| str(S_Ent->Ent,4)+" "+S_Ent->Naim } ))
S_Ent->(DbGoTop())
While ( .t. )
   nKey := 0
   While ( !tb:Stabilize() )
     if ( nKey := m_inkey() ) != 0 ; exit ; end
   end
   nRow := Row()
   if nKey == 0 ; nKey := m_inkey(0)  ; end
   if nKod <> Nil .and. nKey == K_ENTER ; exit ; end
   if nKey == K_ESC ; exit ; end
   if tb:Stable
    do case
       Case nKey == K_F2  // Печать
            nKey := SaveScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1)
            @ MaxRow()-1,01 say padc("Следите за печатью и бумагой",MaxCol()-1) color sset[5]
            nRow := S_Ent->(Recno())
            S_Ent->(DbGoTop())
            Set Device to Print
            @ prow()+1,01 say padc("Распечатка",42)
            @ prow()+1,01 say padc("справочника организаций",42)
            @ prow()+1,01 say repl("-",42)
            @ prow()+1,01 say "Код  Наименование организации"
            @ prow()+1,01 say repl("-",42)
            While ( !S_Ent->(eof()) )
              @ prow()+1,01 say str(S_Ent->Ent,4)+" "+S_Ent->Naim
              S_Ent->(DbSkip(1))
            End
            @ prow()+1,01 say repl("=",42)
            @ prow()+1,01 say ""
            Set Device to Screen
            RestScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1,nKey)
            S_Ent->(DbGoto(nRow))
       Case nKey == K_F6  // Поиск по ключу
            SetCursor(1)
            nKey := SaveScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1)
            @ MaxRow()-1,01 say padc(" ",MaxCol()-1)
            nRow := 0
            @ MaxRow()-1,03 say "Укажите код" get nRow pict "9999" valid nRow > 0
            read
            if LastKey() <> K_ESC
               S_Ent->(DbSeek(str(nRow,4),.t.))
               if S_Ent->(eof())
                  S_Beep(1)  ;  tb:GoBottom()
               end
            end
            SetCursor(0)
            RestScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1,nKey)
            FreshOrder(tb)
       Case nKey == K_F7  // Поиск по наименованию
            SetCursor(1)
            nKey := SaveScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1)
            @ MaxRow()-1,01 say padc(" ",MaxCol()-1)
            nRow := space(30)
            @ MaxRow()-1,01 say "--->" get nRow
            read
            if LastKey() <> K_ESC
               if !S_Locate("Naim",Alltrim(S_Upper(nRow)))
                  S_Beep(1) ;  tb:GoBottom()
               end
            end
            SetCursor(0)
            RestScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1,nKey)
            FreshOrder(tb)
       case nKey == K_F3  // Удаление
           if S_Ent->(Recno()) # 0 .and. S_Err({S_wRow()+1,S_wCol()+2,,;
             "Вы действительно","желаите удалить запись",;
             "и не пожалеите об этом?","% Да ; Нет ;"}) == 1 .and. M_Rlock(20,"S_Ent")
                 S_Ent->(DbDelete())   ; nDelete++
                 S_Ent->(DbUnlock())
                 S_Ent->(DbSkip(1))
                 if S_Ent->(eof()) ; S_Ent->(DbGoBottom()) ; end
           end
           FreshOrder(tb)
       case nKey == K_F4  // Регистрация
           tb:DeHilite()
           EntRec(,nKod)
           FreshOrder(tb)
       case nKey == K_F5  // Корретировка
           tb:DeHilite()
           EntRec(nRow,nKod)
           FreshOrder(tb)
       other
           ApplyKey(nkey,tb)
    end
   end
End
tb := nil
S_wCloseSl(S_RanDom()%22+1)
SetColor(ColorOld)
SetCursor(SursorOld)
if nKod <> Nil .and.nKey == K_ENTER
   nKod := S_Ent->Ent
   @ Row,Col say left(S_Ent->Naim,30)
   if nDelete > 0  ;  pack  ; End
   Select(SelectOld)
   Return ( .t. )
End
if nDelete > 0  ;  pack  ; End
Select(SelectOld)
Return ( .f. )
////////////////////////////////////////////////////////////////////////
Static function EntRec(nRow,nKod)
Local nEnt, cNaim, cOkpo, cMfo, cSchet, cBank, ColorOld
SetCursor(1)
ColorOld := SetColor(COLOR_BAZA)
SursorOld := SetCursor(0)
S_Open_M(07,02,15,40,,sset[2])
if nRow <> Nil
  nEnt := S_Ent->Ent
  @ 01,08 say "Код организации "+str(nEnt,4)
  cNaim := S_Ent->Naim
  cOkpo := S_Ent->Okpo
  cMfo  := S_Ent->Mfo
  cSchet:= S_Ent->Schet
  cBank := S_Ent->Bank
  @ 02,02 get cNaim
  @ 03,02 say "Код ОКПО" get cOkpo
  @ 04,02 say "МФО" get cMfo
  @ 05,02 say "счет" get cSchet
  @ 06,12 say "БАНК"
  @ 07,02 get cBank
  read
  if LastKey() <> K_ESC
      S_Ent->Naim := cNaim
      S_Ent->Okpo := cOkpo
      S_Ent->Mfo  := cMfo
      S_Ent->Schet:= cSchet
      S_Ent->Bank := cBank
  End
else
  BEGIN SEQUENCE
  S_Ent->(DbGoBottom())
  nEnt := S_Ent->Ent + 1
  @ 01,08 say "Код организации" Get nEnt pict "9999" valid nEnt > 0
  if LastKey() == K_ESC ; Break ; End
  if S_Ent->(DbSeek(str(nEnt,4)))
     @ 02,06 say padc(" Запись имеется ",33) Color sset[5]
     inkey(0)
     break
  End
  cNaim := S_Ent->Naim
  cOkpo := S_Ent->Okpo
  cMfo  := S_Ent->Mfo
  cSchet:= S_Ent->Schet
  cBank := S_Ent->Bank
  @ 02,02 get cNaim
  @ 03,02 say "Код ОКПО" get cOkpo
  @ 04,02 say "МФО" get cMfo
  @ 05,02 say "счет" get cSchet
  @ 06,12 say "БАНК"
  @ 07,02 get cBank
  read
  if LastKey() == K_ESC ; break ; End
  S_Ent->(DbAppend())
  S_Ent->Ent  := nEnt
  S_Ent->Naim := cNaim
  S_Ent->Okpo := cOkpo
  S_Ent->Mfo  := cMfo
  S_Ent->Schet:= cSchet
  S_Ent->Bank := cBank
  END SEQUENCE
End
S_wCloseSl(S_RanDom()%22+1)
SetColor(ColorOld)
SetCursor(1)
Return ( nil )
/////////////////////////////////////////////////////////////////////////
Function VedChet(nKod,Row,Col)
Local tb, ColorOld, SelectOld := Select(), SursorOld, nKey, nRow, GetList := {}
Local nDelete := 0
Local NortonOld := DeskTop:norton()
if nKod <> Nil .and. S_Chet->(DbSeek(Str(nKod,5,2)))
  if Row <> Nil
     @ Row,Col say S_Chet->Naim
  End
  Return ( .t. )
End
ColorOld := SetColor(COLOR_NSI)
SursorOld := SetCursor(0)
DbSelectArea("S_CHET")
S_Open_M(02,38,22,75,,sset[2])
@ 01,01 say "Код  Наименование счета"
@ 02,01 say Repl([─],MaxCol()-1)
@ MaxRow()-2,01 say Repl([─],MaxCol()-1)
@ MaxRow()-1,01 say padc("2печ 3уд 4рег 5корр 6поиск 7поиск 9режим",MaxCol()-1) color sset[5]
tb := TBrowseDb(03,01,MaxRow()-3,MaxCol()-1)
tb:AddColumn(TbColumnNew("" ,{|| str(S_Chet->Chet,5,2)+" "+S_Chet->Naim } ))
S_Chet->(DbGoTop())
While ( .t. )
   nKey := 0
   While ( !tb:Stabilize() )
     if ( nKey := m_inkey() ) != 0 ; exit ; end
   end
   nRow := Row()
   if nKey == 0 ; nKey := m_inkey(0)  ; end
   if nKod <> Nil .and. nKey == K_ENTER ; exit ; end
   if nKey == K_ESC ; exit ; end
   if tb:Stable
    do case
       Case nKey == K_F2  // Печать
            nKey := SaveScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1)
            @ MaxRow()-1,01 say padc("Следите за печатью и бумагой",MaxCol()-1) color sset[5]
            nRow := S_Chet->(Recno())
            S_Chet->(DbGoTop())
            Set Device to Print
            @ prow()+1,01 say padc("Распечатка",38)
            @ prow()+1,01 say padc("справочника счетов",38)
            @ prow()+1,01 say repl("-",38)
            @ prow()+1,01 say "Код  Наименование счета"
            @ prow()+1,01 say repl("-",38)
            While ( !S_Chet->(eof()) )
              @ prow()+1,01 say str(S_Chet->Chet,5,2)+" "+S_Chet->Naim
              S_Chet->(DbSkip(1))
            End
            @ prow()+1,01 say repl("=",38)
            @ prow()+1,01 say ""
            Set Device to Screen
            RestScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1,nKey)
            S_Chet->(DbGoto(nRow))
       Case nKey == K_F6  // Поиск по ключу
            SetCursor(1)
            nKey := SaveScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1)
            @ MaxRow()-1,01 say padc(" ",MaxCol()-1)
            nRow := 0
            @ MaxRow()-1,03 say "Укажите счет" get nRow pict "99.99" valid nRow > 0
            read
            if LastKey() <> K_ESC
               S_Chet->(DbSeek(str(nRow,5,2),.t.))
               if S_Chet->(eof())
                  S_Beep(1)  ;  tb:GoBottom()
               end
            end
            SetCursor(0)
            RestScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1,nKey)
            FreshOrder(tb)
       Case nKey == K_F7  // Поиск по наименованию
            SetCursor(1)
            nKey := SaveScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1)
            @ MaxRow()-1,01 say padc(" ",MaxCol()-1)
            nRow := space(30)
            @ MaxRow()-1,01 say "--->" get nRow
            read
            if LastKey() <> K_ESC
               if !S_Locate("Naim",Alltrim(S_Upper(nRow)))
                  S_Beep(1) ;  tb:GoBottom()
               end
            end
            SetCursor(0)
            RestScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1,nKey)
            FreshOrder(tb)
       case nKey == K_F3  // Удаление
           if S_Chet->(Recno()) # 0 .and. S_Err({S_wRow()+1,S_wCol()+2,,;
             "Вы действительно","желаите удалить запись",;
             "и не пожалеите об этом?","% Да ; Нет ;"}) == 1 .and. M_Rlock(20,"S_Chet")
                 S_Chet->(DbDelete())  ;  nDelete++
                 S_Chet->(DbUnlock())
                 S_Chet->(DbSkip(1))
                 if S_Chet->(eof()) ; S_Chet->(DbGoBottom()) ; end
           end
           FreshOrder(tb)
       case nKey == K_F4  // Регистрация
           tb:DeHilite()
           ChetRec(,nKod)
           FreshOrder(tb)
       case nKey == K_F5  // Корретировка
           tb:DeHilite()
           ChetRec(nRow,nKod)
           FreshOrder(tb)
       other
           ApplyKey(nkey,tb)
    end
   end
End
tb := Nil
S_wCloseSl(S_RanDom()%22+1)
SetColor(ColorOld)
SetCursor(SursorOld)
if nKod <> Nil .and.nKey == K_ENTER
   nKod := S_Chet->Chet
   if Row <> Nil
      @ Row,Col say S_Chet->Naim
   End
   if nDelete > 0  ;  pack  ; End
   Select(SelectOld)
   Return ( .t. )
End
if nDelete > 0  ;  pack  ; End
Select(SelectOld)
Return ( .f. )
////////////////////////////////////////////////////////////////////////
Static function ChetRec(nRow,nKod)
Local nChet, cNaim
      cSay := SaveScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1)
SetCursor(1)
if nRow <> Nil
  @ MaxRow()-1,01 say padc("Корректируйте наименование",MaxCol()-1) color sset[5]
  cNaim := S_Chet->Naim
  @ nRow,07 get cNaim
  read
  if LastKey() <> K_ESC //.and. M_Rlock(20,"S_Chet")
      S_Chet->Naim := cNaim
//      S_Chet->(DbUnlock())
  End
else
 @ MaxRow()-1,01 say padc("Вставляйте записи",MaxCol()-1) color sset[5]
 While ( .t. )
   Scroll(03,01,MaxRow()-3,MaxCol()-1,-1)
   nChet := 0
   @ 03,01 get nChet Pict "99.99" valid nChet > 0
   read
   if LastKey() == K_ESC ; Exit ; End
   if S_Chet->(DbSeek(str(nChet,5,2)))
      @ 03,07 say padc(" Запись имеется ",30) Color sset[5]
      loop
   End
   cNaim := space(30)
   @ 03,07 get cNaim
   read
   if LastKey() <> K_ESC
      S_Chet->(DbAppend())
      S_Chet->Chet := nChet  ;  S_Chet->Naim := S_Upper(cNaim)
   End
   if nKod <> Nil ; exit ; End
 End
End
RestScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1,cSay)
SetCursor(1)
Return ( nil )
///////////////////////////////////////////////////////////////////////////
Function ApplyKey(nKey,o)
Do case
   case nKey == K_DOWN       ;  o:Down()
   case nKey == K_UP         ;  o:Up()
   case nKey == K_RIGHT      ;  o:Right()
   case nKey == K_LEFT       ;  o:Left()
   case nKey == K_PGDN       ;  o:PageDown()
   case nKey == K_PGUP       ;  o:PageUp()
   case nKey == K_HOME       ;  o:Home()
   case nKey == K_END        ;  o:End()
   case nKey == K_CTRL_PGUP  ;  o:GoTop()
   case nKey == K_CTRL_PGDN  ;  o:GoBottom()
   case nKey == K_CTRL_LEFT  ;  o:PanLeft()
   case nKey == K_CTRL_RIGHT ;  o:PanRight()
   case nKey == K_CTRL_HOME  ;  o:PanHome()
   case nKey == K_CTRL_END   ;  o:PanEnd()
end
return ( Nil )
////////////////////////////////////////////////////////////////////////////
Function FreshOrder(o)
o:RefReshAll()
While ( !o:stabilize() ) ; end
return ( Nil )
/////////////////////////////////////////////////////////////////////////////
Function M_inkey( nSecond )
local nKey  := if( nSecond == NIL, inkey(), inkey(nSecond) )
local bKeyBlock := setkey(nKey)
if bKeyBlock # NIL
   eval( bKeyBlock, procname(2), procline(2), readvar() )
end
return (nKey)
/////////////////////////////////////////////////////////////////////////////
Function My_Char()
aeval({ {523,2},{698,2},{880,2},{1046,4},{880,2},{1046,4}  },;
      { |x| tone(x[1], x[2])  } )
return ( Nil )
/////////////////////////////////////////////////////////////////////////////
Function VedMat(nKod,Row,Col)
Local tb, ColorOld, SelectOld := Select(), SursorOld, nKey, nRow, GetList := {}
Local nDelete := 0, nK_Mat, cNaim, nKSchet, cEdIzm, nCena
Local nLocate := 0, cLocate := ""

if nKod <> Nil .and. S_Mat->(DbSeek(Str(nKod,5)))
  if Row <> Nil
     @ Row,Col say S_Mat->Naim
  End
  Return ( .t. )
End
ColorOld := SetColor(COLOR_NSI)
SursorOld := SetCursor(0)
DbSelectArea("S_MAT")
S_Open_M(02,01,22,65,,sset[2])
@ 01,01 say "К.мат  Ед.из к  сч    Наименование         Max цена  Срок н  Пр"
@ 02,01 say Repl([─],MaxCol()-1)
@ MaxRow()-2,01 say Repl([─],MaxCol()-1)
@ MaxRow()-1,01 say padc("2печ 3уд 4рег 5корр 6поиск 7поиск 8Прод",MaxCol()-1) color sset[5]
tb := TBrowseDb(03,01,MaxRow()-3,MaxCol()-1)
tb:AddColumn(TbColumnNew("" ,{|| str(S_Mat->K_Mat,5)+" "+S_Mat->EdIzm+" "+;
             str(S_Mat->KSChet,5,2)+" "+S_Mat->Naim+" "+str(S_Mat->Cena,11,2)+;
             str(S_Mat->SrNos,6,2)+" "+str(S_Mat->Pr,1)+" " } ))
S_Mat->(DbGoTop())
While ( .t. )
   nKey := 0
   While ( !tb:Stabilize() )
     if ( nKey := m_inkey() ) != 0 ; exit ; end
   end
   nRow := Row()
   if nKey == 0 ; nKey := m_inkey(0)  ; end
   if nKod <> Nil .and. nKey == K_ENTER ; exit ; end
   if nKey == K_ESC ; exit ; end
   if tb:Stable
    do case
       Case nKey == K_F2  // Печать
            nKey := SaveScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1)
            @ MaxRow()-1,01 say padc("Следите за печатью и бумагой",MaxCol()-1) color sset[5]
            nRow := S_Mat->(Recno())
            S_Mat->(DbGoTop())
            Set Device to Print
            @ prow()+1,01 say padc("Распечатка",55)
            @ prow()+1,01 say padc("справочника материалов",55)
            @ prow()+1,01 say repl("-",64)
            @ prow()+1,01 say "К.мат  Ед.из к  сч    Наименование        Max цена   Срок н  Пр"
            @ prow()+1,01 say repl("-",64)
            While ( !S_Mat->(eof()) )
              @ prow()+1,01 say str(K_Mat,5)+" "+S_Mat->EdIzm+" "+;
                 str(S_Mat->KSChet,5,2)+" "+S_Mat->Naim+" "+str(S_Mat->Cena,11,2)+" "+;
                 str(S_Mat->SrNos,5,2)+" "+str(S_Mat->Pr,1)
              S_Mat->(DbSkip(1))
            End
            @ prow()+1,01 say repl("=",64)
            @ prow()+1,01 say ""
            Set Device to Screen
            RestScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1,nKey)
            S_Mat->(DbGoto(nRow))
       Case nKey == K_F6  // Поиск по ключу
            SetCursor(1)
            nKey := SaveScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1)
            @ MaxRow()-1,01 say padc(" ",MaxCol()-1)
            nRow := 0
            @ MaxRow()-1,03 say "Укажите код" get nRow pict "99999" valid nRow > 0
            read
            if LastKey() <> K_ESC
               S_Mat->(DbSeek(str(nRow,5),.t.))
               if S_Mat->(eof())
                  S_Beep(1)  ;  tb:GoBottom()
               end
            end
            SetCursor(0)
            RestScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1,nKey)
            FreshOrder(tb)
       Case nKey == K_F7  // Поиск по наименованию
            SetCursor(1)
            nKey := SaveScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1)
            @ MaxRow()-1,01 say padc(" ",MaxCol()-1)
            cLocate := space(25)
            @ MaxRow()-1,01 say "--->" get cLocate
            read
            if LastKey() <> K_ESC
               nRow := S_Mat->(Recno())
               nLocate := 0
               S_Mat->(DbGoTop())
               @ MaxRow()-1,01 say padc("Ожидайте",MaxCol()-1)
               cLocate := S_Upper(Alltrim(cLocate))
               While ( !S_Mat->(eof()) )
                 if cLocate $ S_Upper(S_Mat->Naim)
                    nLocate := S_Mat->(Recno())
                    Exit
                 End
                 S_Mat->(DbSkip(1))
               End
               if nLocate == 0
                  S_Err({"Данные не найдены"})
                  cLocate := ""
                  S_Mat->(DbGoto(nRow))
               end
            End
            SetCursor(0)
            RestScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1,nKey)
            FreshOrder(tb)
       Case nKey == K_F8 .and. !Empty(cLocate) // Продолжение поиск по наименованию
            nKey := SaveScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1)
            @ MaxRow()-1,01 say padc("Ожидайте",MaxCol()-1)
            nRow := S_Mat->(Recno())
            S_Mat->(DbGoto(nLocate))
            S_Mat->(DbSkip(1))
            nLocate := 0
            While ( !S_Mat->(eof()) )
              if cLocate $ S_Upper(S_Mat->Naim)
                 nLocate := S_Mat->(Recno())
                 Exit
              End
              S_Mat->(DbSkip(1))
            End
            if nLocate == 0
                  S_Err({"Данные не найдены"})
                  cLocate := ""
                  S_Mat->(DbGoto(nRow))
            end
            RestScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1,nKey)
            FreshOrder(tb)
       case nKey == K_F3  // Удаление
           if S_Mat->(Recno()) # 0 .and. S_Err({S_wRow()+1,S_wCol()+2,,;
             "Вы действительно","желаите удалить запись",;
             "и не пожалеите об этом?","% Да ; Нет ;"}) == 1 .and. M_Rlock(20,"S_Mat")
                 S_Mat->(DbDelete())  ;  nDelete++
                 S_Mat->(DbUnlock())
                 S_Mat->(DbSkip(1))
                 if S_Mat->(eof()) ; S_Mat->(DbGoBottom()) ; end
           end
           FreshOrder(tb)
       case nKey == K_F4  // Регистрация
           @ 03,01 say padc(" ",MaxCol()-1)
           SetCursor(1)
           nKey := SaveScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1)
           @ MaxRow()-1,01 say padc("Регистрируте",MaxCol()-1) color sset[15]
           BEGIN SEQUENCE
           cEdIzm  := "    "
           nKSchet := nK_Mat := nCena := nSrNos := nPr := 0
           cNaim   := space(25)
           @ 03,01 get nK_Mat pict "99999" valid nK_Mat > 0
           read
           if LastKey() == K_ESC ; break ; End
           if S_Mat->(Dbseek(str(nK_Mat,5)))
              S_Beep(1)
              @ 03,18 say " Уже имеется "
              inkey(2)
              break
           End
           @ 03,07 get cEdIzm valid !Empty(cEdIzm)
           @ 03,12 get nKSchet pict "99.99" valid VedChet(@nKSchet)
           @ 03,18 get cNaim valid !Empty(cNaim)
           @ 03,44 get nCena pict "99999999.99" valid nCena >= 0
           @ 03,56 get nSrNos pict "99.99" 
           @ 03,62 get nPr pict "9" range 0,1
           read
           if LastKey() == K_ESC ; break ; End
           if !M_Append(20,"S_MAT") ; break ; End
           S_Mat->K_Mat   := nK_Mat
           S_Mat->EdIzm   := cEdIzm
           S_Mat->KSchet  := nKSchet
           S_Mat->Naim    := cNaim
           S_Mat->Cena    := nCena
           S_Mat->SrNos   := nSrNos
           S_Mat->Pr      := nPr
           S_Mat->(DbUnlock())
           END SEQUENCE
           SetCursor(0)
           RestScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1,nKey)
           FreshOrder(tb)
       case nKey == K_F5  // Корретировка
           tb:DeHilite()
           cEdIzm  := S_Mat->EdIzm
           nKSchet := S_Mat->KSchet
           cNaim   := S_Mat->Naim
           nCena   := S_Mat->Cena
           nSrNos  := S_Mat->SrNos
           nPr     := S_Mat->Pr
           SetCursor(1)
           nKey := SaveScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1)
           @ MaxRow()-1,01 say padc(" Корректируйте",MaxCol()-1) color sset[15]
           BEGIN SEQUENCE
           @ nRow,07 get cEdIzm valid !Empty(cEdIzm)
           @ nRow,12 get nKSchet pict "99.99" valid VedChet(@nKSchet)
           @ nRow,18 get cNaim valid !Empty(cNaim)
           @ nRow,44 get nCena pict "99999999.99" valid nCena >= 0
           @ nRow,56 get nSrNos pict "99.99" 
           @ nRow,62 get nPr pict "9" range 0,1
           read
           if LastKey() == K_ESC ; break ; End
           if !M_Rlock(20,"S_MAT") ; break ; End
           S_Mat->EdIzm   := cEdIzm
           S_Mat->KSchet  := nKSchet
           S_Mat->Naim    := cNaim
           S_Mat->Cena    := nCena
           S_Mat->SrNos   := nSrNos
           S_Mat->Pr      := nPr
           S_Mat->(DbUnlock())
           END SEQUENCE
           SetCursor(0)
           RestScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1,nKey)
           FreshOrder(tb)
       other
           ApplyKey(nkey,tb)
    end
   end
End
tb := Nil
S_wCloseSl(S_RanDom()%22+1)
SetColor(ColorOld)
SetCursor(SursorOld)
if nKod <> Nil .and.nKey == K_ENTER
   nKod := S_Mat->K_Mat
   if Row <> Nil
      @ Row,Col say S_Mat->Naim
   End
   Select(SelectOld)
   Return ( .t. )
End
Select(SelectOld)
Return ( .f. )
/////////////////////////////////////////////////////////////////////////////
Function VedTabN(nKod,Row,Col)
Local tb, ColorOld, SelectOld := Select(), SursorOld,nKey, nRow, GetList := {},;
      nDelete := 0
      
if Tn->(DbSeek(nKod))
   @ Row,Col say Tn->Fio
   Return ( .t. )
End
DbSelectArea("Tn")
DbSetOrder(2)
ColorOld := SetColor(COLOR_NSI)
SursorOld := SetCursor(0)
S_Open_M(02,33,22,66,,sset[2])
@ 01,01 say "Подр Таб.N  Фамилия"
@ 02,01 say Repl([─],MaxCol()-1)
tb := TBrowseDb(03,01,MaxRow()-1,MaxCol()-1)
tb:AddColumn(TbColumnNew("" ,{|| TN->Ksp+" "+TN->Tn+" "+Tn->Fio } ))
Tn->(DbGoTop())
While !Tn->(eof())
  if Tn->Ksp <> "****" ; Exit ; End
  Tn->(DbSkip(1))
End
While ( .t. )
   nKey := 0
   While ( !tb:Stabilize() )
     if ( nKey := m_inkey() ) != 0 ; exit ; end
   end
   nRow := Row()
   if nKey == 0 ; nKey := m_inkey(0)  ; end
   if nKey == K_ENTER .or. nKey == K_ESC ; exit ; end
   if tb:Stable  ;  ApplyKey(nkey,tb)  ;  end
End
tb := nil
S_wCloseSl(S_RanDom()%22+1)
SetColor(ColorOld)
SetCursor(SursorOld)
if nKey == K_ENTER
   nKod := Tn->Tn
   @ Row,Col say Tn->Fio
   nKey := Tn->(Recno())
   DbSetOrder(1)
   Tn->(DbGoto(nKey))
   Select(SelectOld)
   Return ( .t. )
End
Select(SelectOld)
Return ( .f. )
////////////////////////////////////////////////////////////////////////////
