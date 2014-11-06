#include "Mater.ch"
#include "Inkey.ch"
#Define NOM_KEY 30
#Define ROUND_CENA 2
#Define ROUND_S14  2
/////////////////////////////////////////////////////////////////////////////
Function VedPrix()  // Ведение прихода
Local tb, ColorOld, SursorOld, nKey, nRow, GetList := {}
Local nNnak, nK_Mat, nEnt, nKol, nSum, nCena

ColorOld := SetColor(COLOR_BAZA)
SursorOld := SetCursor(0)
BEGIN SEQUENCE
if !OpenDbf_(sset[SSET_BAZA]+"S_Chet") ;  break ; End
if !OpenDbf_(sset[SSET_BAZA]+"S_Ent")  ;  break ; End
if !OpenDbf_(sset[SSET_BAZA]+"S_Mat")  ;  break ; End
if !OpenDbf_(sset[SSET_BAZA]+"Prixod") ;  break ; End
Set relation to str(Ent,4) into S_Ent,;
             to str(K_Mat,5) into S_Mat
DbSelectArea("Prixod")
S_Open_M(02,01,22,74,,sset[2])
@ 01,01 say "K.мат К.ор  К-во        Сумма     N  нак  к.сч    Наименование"
@ 02,01 say Repl([─],MaxCol()-1)
@ MaxRow()-3,01 say Repl([─],MaxCol()-1)
@ MaxRow()-2,01 say "Наименование организации"
@ MaxRow()-1,01 say padc("3удалить 4регистрировать 5корректировать ",MaxCol()-1) color sset[5]
tb := TBrowseDb(03,01,MaxRow()-4,MaxCol()-1)
tb:AddColumn(TbColumnNew("" ,{|| str(Prixod->K_Mat,5)+" "+str(Prixod->Ent,4)+" "+;
   str(Prixod->Kol,10,3)+" "+str(Prixod->Sum,11,2)+" "+str(Prixod->Nnak,6)+" "+;
   str(Prixod->KSChet,5,2)+" "+S_Mat->Naim } ))
Prixod->(DbGoTop())
While ( .t. )
   nKey := 0
   While ( !tb:Stabilize() )
     if ( nKey := m_inkey() ) != 0 ; exit ; end
   end
   nRow := Row()
   @ MaxRow()-2,27 say S_Ent->Naim
   if nKey == 0 ; nKey := m_inkey(0)  ; end
   if nKey == K_ESC ; exit ; end
   if tb:Stable
    do case
       case nKey == K_F3  // Удаление
           if Prixod->(Recno()) # 0 .and. S_Err({S_wRow()+1,S_wCol()+2,,;
             "Вы действительно","желаите удалить запись",;
             "и не пожалеите об этом?","% Да ; Нет ;"}) == 1 .and. M_Rlock(20,"Prixod")
                 Prixod->(DbDelete())
                 Prixod->(DbUnlock())
                 Prixod->(DbSkip(1))
                 if Prixod->(eof()) ; Prixod->(DbGoBottom()) ; end
           end
           FreshOrder(tb)
       case nKey == K_F4  // Регистрация
           @ 03,01 say padc(" ",MaxCol()-1)
           SetCursor(1)
           nKey := SaveScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1)
           @ MaxRow()-1,01 say padc("Регистрируте данные",MaxCol()-1) color sset[15]
           While ( .t. )
            Scroll(03,01,MaxRow()-4,MaxCol()-1,-1)
            @ MaxRow()-2,27 say space(30)
            nK_Mat := nEnt := nKol := nSum := nNnak := 0
            @ 03,01 get nK_Mat pict "99999" valid VedMat(@nK_Mat,03,48)
            read
            if LastKey() == K_ESC ; Exit ; End
            nKSchet := S_Mat->KSchet
            @ 03,42 say nKSchet pict "99.99"
            @ 03,07 get nEnt pict "9999" valid VedEnt(@nEnt,MaxRow()-2,27)
            @ 03,12 get nKol pict "999999.999" //valid nKol > 0
            @ 03,23 get nSum pict "99999999.99" //valid nSum > 0
            @ 03,35 get nNnak pict "999999"
            read
            if LastKey() == K_ESC ; break ; End
            if !M_Append(20,"Prixod") ; break ; End
            Prixod->K_Mat   := nK_Mat
            Prixod->Ent     := nEnt
            Prixod->Nnak    := nNnak
            Prixod->KSchet  := nKSchet
            Prixod->Kol     := nKol
            Prixod->Sum     := nSum
            Prixod->(DbUnlock())
            nCena := Round(nSum/nKol,ROUND_CENA)
            if nCena > S_Mat->Cena .and. M_Rlock(20,"S_Mat")
               S_Mat->Cena := nCena
               S_Mat->(DbUnlock())
            End
           End
           SetCursor(0)
           RestScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1,nKey)
           Prixod->(DbGoTop())
           FreshOrder(tb)
       case nKey == K_F5  // Корретировка
           tb:DeHilite()
           nKol  := Prixod->Kol
           nSum  := Prixod->Sum
           nNnak := Prixod->Nnak
           SetCursor(1)
           nKey := SaveScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1)
           @ MaxRow()-1,01 say padc("Корректируйте данные",MaxCol()-1) color sset[15]
           BEGIN SEQUENCE
           @ nRow,12 get nKol pict "999999.999" //valid nKol > 0
           @ nRow,23 get nSum pict "99999999.99" //valid nSum > 0
           @ nRow,35 get nNnak pict "999999"
           read
           if LastKey() == K_ESC ; break ; End
           if !M_RLock(20,"Prixod") ; break ; End
           Prixod->Nnak    := nNnak
           Prixod->Kol     := nKol
           Prixod->Sum     := nSum
           Prixod->(DbUnlock())
           nCena := Round(nSum/nKol,ROUND_CENA)
           if nCena > S_Mat->Cena .and. M_Rlock(20,"S_Mat")
             S_Mat->Cena := nCena
             S_Mat->(DbUnlock())
           End
           END SEQUENCE
           SetCursor(0)
           RestScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1,nKey)
           FreshOrder(tb)
       other
           ApplyKey(nkey,tb)
    end
   end
End
S_wCloseSl(S_RanDom()%22+1)
END SEQUENCE
SetColor(ColorOld)
SetCursor(SursorOld)
DbCloseAll()
Return ( Nil )
/////////////////////////////////////////////////////////////////////////////
Function VedRasx()  // Ведение расхода
Local tb, ColorOld, SursorOld, nKey, nRow, GetList := {}
Local nNnak, nK_Mat, nKol, nSum, nCena

ColorOld := SetColor(COLOR_BAZA)
SursorOld := SetCursor(0)
if !file(sset[SSET_DIRTN]+"Superlis.Dbf")
  My_Char()
  S_Err({"Отсутствует справочник работающих"})
  Return ( Nil )
End
if !file(sset[SSET_DIRTN]+"Ssp.Dbf")
  My_Char()
  S_Err({"Отсутствует справочник подразделений"})
  Return ( Nil )
End
BEGIN SEQUENCE
OpenTn()
OpenKsp()
set index to (sset[SSET_DIRTN]+"Ssp.Ntx")
if !OpenDbf_(sset[SSET_BAZA]+"S_Chet") ;  break ; End
if !OpenDbf_(sset[SSET_BAZA]+"S_Mat")  ;  break ; End
if !OpenDbf_(sset[SSET_BAZA]+"Rasxod") ;  break ; End
Set relation to str(K_Mat,5) into S_Mat,;
             to TabN into TN
DbSelectArea("Rasxod")
S_Open_M(03,01,22,75,,sset[2])
@ 01,01 say "К.мат Субсч  к-во       Сумма      N нак  к.сч    Наименование"
@ 02,01 say Repl([─],MaxCol()-1)
@ MaxRow()-3,01 say Repl([─],MaxCol()-1)
@ MaxRow()-2,01 say "Таб. No"
@ MaxRow()-2,37 say "Подраз."
@ MaxRow()-2,50 say "Дата/пол"
@ MaxRow()-1,01 say padc("3удалить 4регистрировать 5корректировать ",MaxCol()-1) color sset[5]
tb := TBrowseDb(03,01,MaxRow()-4,MaxCol()-1)
tb:AddColumn(TbColumnNew("" ,{|| str(Rasxod->K_Mat,5)+" "+str(Rasxod->DSchet,5,2)+" "+;
   str(Rasxod->Kol,10,3)+" "+str(Rasxod->Sum,11,2)+" "+str(Rasxod->Nnak,6)+" "+;
   str(Rasxod->KSChet,5,2)+" "+S_Mat->Naim } ))
Rasxod->(DbGoTop())
While ( .t. )
   nKey := 0
   While ( !tb:Stabilize() )
     if ( nKey := m_inkey() ) != 0 ; exit ; end
   end
   nRow := Row()
   @ MaxRow()-2,09 say Rasxod->TabN
   @ MaxRow()-2,16 say Tn->Fio
   @ MaxRow()-2,45 say Rasxod->Ksp
   @ MaxRow()-2,59 say Rasxod->DataP pict "@d"
   if nKey == 0 ; nKey := m_inkey(0)  ; end
   if nKey == K_ESC ; exit ; end
   if tb:Stable
    do case
       case nKey == K_F3  // Удаление
           if Rasxod->(Recno()) # 0 .and. S_Err({S_wRow()+1,S_wCol()+2,,;
             "Вы действительно","желаите удалить запись",;
             "и не пожалеите об этом?","% Да ; Нет ;"}) == 1 .and. M_Rlock(20,"Rasxod")
                 Rasxod->(DbDelete())
                 Rasxod->(DbUnlock())
                 Rasxod->(DbSkip(1))
                 if Rasxod->(eof()) ; Rasxod->(DbGoBottom()) ; end
           end
           FreshOrder(tb)
       case nKey == K_F4  // Регистрация
           @ 03,01 say padc(" ",MaxCol()-1)
           SetCursor(1)
           nKey := SaveScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1)
           @ MaxRow()-1,01 say padc("Регистрируте данные",MaxCol()-1) color sset[15]
           While ( .t. )
            Scroll(03,01,MaxRow()-4,MaxCol()-1,-1)
            nK_Mat := nKol := nSum := nNnak := nDSchet := 0
            cTn := space(6)
            @ 03,01 get nK_Mat pict "99999" valid VedMat(@nK_Mat,03,49)
            read
            if LastKey() == K_ESC ; Exit ; End
            nKSchet := S_Mat->KSchet
            @ 03,43 say nKSchet pict "99.99"
            @ 03,07 get nDSchet pict "99.99" valid VedChet(@nDschet)
            @ 03,13 get nKol pict "999999.999" //valid nKol > 0
            read
            if LastKey() == K_ESC ; break ; End
            nSum := Round(nKol*S_Mat->Cena,ROUND_S14)
            @ 03,24 get nSum pict "99999999.99" //valid nSum > 0
            @ 03,36 get nNnak pict "999999"
            @ MaxRow()-2,09 get cTn valid cTn<>"******" .and. VedTabN(@cTn,MaxRow()-2,16)
            read
            if LastKey() <> K_ESC
              cKsp := Tn->Ksp
              dDataP := sset[SSET_DATA]
              @ MaxRow()-2,45 get cKsp
              @ MaxRow()-2,59 get dDataP pict "@d" valid !Empty(dDataP)
              read
              if LastKey() == K_ESC ; break ; End
            else
              cTn := cKsp := ""
              dDataP := ctod("")
            End
            if !M_Append(20,"Rasxod") ; break ; End
            Rasxod->K_Mat   := nK_Mat
            Rasxod->Nnak    := nNnak
            Rasxod->KSchet  := nKSchet
            Rasxod->DSchet  := nDSchet
            Rasxod->Kol     := nKol
            Rasxod->Sum     := nSum
            Rasxod->TabN    := cTn
            Rasxod->Ksp     := cKsp
            Rasxod->DataP   := dDataP
            Rasxod->(DbUnlock())
           End
           SetCursor(0)
           RestScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1,nKey)
           Rasxod->(DbGoTop())
           FreshOrder(tb)
       case nKey == K_F5  // Корретировка
           tb:DeHilite()
           nKol  := Rasxod->Kol
           nSum  := Rasxod->Sum
           nNnak := Rasxod->Nnak
           nDSchet := Rasxod->DSchet
           cTn := Rasxod->TabN
           dDataP := Rasxod->DataP
           SetCursor(1)
           nKey := SaveScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1)
           @ MaxRow()-1,01 say padc("Корректируйте данные",MaxCol()-1) color sset[15]
           BEGIN SEQUENCE
           @ nRow,07 get nDSchet pict "99.99" valid VedChet(@nDschet)
           @ nRow,13 get nKol pict "999999.999" //valid nKol > 0
           @ nRow,24 get nSum pict "99999999.99" //valid nSum > 0
           @ nRow,36 get nNnak pict "999999"
           @ MaxRow()-2,09 get cTn valid cTn<>"******" .and. VedTabN(@cTn,MaxRow()-2,16)
           read
           if LastKey() <> K_ESC
             cKsp := Tn->Ksp
             @ MaxRow()-2,45 get cKsp
             @ MaxRow()-2,59 get dDataP pict "@d" valid !Empty(dDataP)
             read
             if LastKey() == K_ESC ; break ; End
           else
             cTn := cKsp := ""
             dDataP := ctod("")
           End
           if !M_RLock(20,"Rasxod") ; break ; End
           Rasxod->Nnak    := nNnak
           Rasxod->Kol     := nKol
           Rasxod->Sum     := nSum
           Rasxod->DSchet  := nDSchet
           Rasxod->TabN    := cTn
           Rasxod->Ksp     := cKsp
           Rasxod->DataP   := dDataP
           Rasxod->(DbUnlock())
           END SEQUENCE
           SetCursor(0)
           RestScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1,nKey)
           FreshOrder(tb)
       other
           ApplyKey(nkey,tb)
    end
   end
End
S_wCloseSl(S_RanDom()%22+1)
END SEQUENCE
SetColor(ColorOld)
SetCursor(SursorOld)
DbCloseAll()
Return ( Nil )
/////////////////////////////////////////////////////////////////////////////
Function VedOst()  // Ведение остатков
Local tb, ColorOld, SursorOld, nKey, nRow, GetList := {}
Local nNnak, nK_Mat, nKol, nSum, nRegim, nCena

ColorOld := SetColor(COLOR_BAZA)
SursorOld := SetCursor(0)
BEGIN SEQUENCE
if !OpenDbf_(sset[SSET_BAZA]+"S_Chet") ;  break ; End
if !OpenDbf_(sset[SSET_BAZA]+"S_Mat")  ;  break ; End
if !OpenDbf_(sset[SSET_BAZA]+"OstMat") ;  break ; End
Set relation to str(K_Mat,5) into S_Mat
DbSelectArea("OstMat")
S_Open_M(02,01,22,62,,sset[2])
@ 01,01 say "К.мат  к.сч   к-во       сумма       Наименование"
@ 02,01 say Repl([─],MaxCol()-1)
@ MaxRow()-2,01 say Repl([─],MaxCol()-1)
@ MaxRow()-1,01 say padc("3удалить 4регистр 5коррек 6удалНУЛЬ ",MaxCol()-1) color sset[5]
tb := TBrowseDb(03,01,MaxRow()-3,MaxCol()-1)
tb:AddColumn(TbColumnNew("" ,{|| str(OstMat->K_Mat,5)+" "+str(OstMat->KSchet,5,2)+" "+;
   str(OstMat->Kol,10,3)+" "+str(OstMat->Sum,11,2)+" "+S_Mat->Naim } ))
OstMat->(DbGoTop())
While ( !tb:Stabilize() ) ; End
nRegim := S_Err({"Укажите режим корректировки цены?",;
                 "%  Корректировать  ;  Не корректировать  ;"})
While ( .t. )
   nKey := 0
   While ( !tb:Stabilize() )
     if ( nKey := m_inkey() ) != 0 ; exit ; end
   end
   nRow := Row()
   if nKey == 0 ; nKey := m_inkey(0)  ; end
   if nKey == K_ESC ; exit ; end
   if tb:Stable
    do case
       case nKey == K_F3  // Удаление
           if OstMat->(Recno()) # 0 .and. S_Err({S_wRow()+1,S_wCol()+2,,;
             "Вы действительно","желаите удалить запись",;
             "и не пожалеите об этом?","% Да ; Нет ;"}) == 1 .and. M_Rlock(20,"OstMat")
                 OstMat->(DbDelete())
                 OstMat->(DbUnlock())
                 OstMat->(DbSkip(1))
                 if OstMat->(eof()) ; OstMat->(DbGoBottom()) ; end
           end
           FreshOrder(tb)
       case nKey == K_F6  // Удалить нулевые остатки
           if S_Err({S_wRow()+1,S_wCol()+2,,;
             "Вы действительно","желаите удалить нулевые остатки",;
             "и не пожалеите об этом?","% Да ; Нет ;"}) == 1
              S_Sys({"Минутку"})
              OstMat->(DbGoTop())
              While !OstMat->(eof())
                if OstMat->Kol == 0 .and. OstMat->Sum == 0 .and. M_Rlock(20,"OstMat")
                    OstMat->(DbDelete())
                    OstMat->(DbUnlock())
                 End
                 OstMat->(DbSkip(1))
              End
              S_Sys()
              OstMat->(DbGoTop())
           end
           FreshOrder(tb)
       case nKey == K_F4  // Регистрация
           @ 03,01 say padc(" ",MaxCol()-1)
           SetCursor(1)
           nKey := SaveScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1)
           @ MaxRow()-1,01 say padc("Регистрируте данные",MaxCol()-1) color sset[15]
           While ( .t. )
            Scroll(03,01,MaxRow()-3,MaxCol()-1,-1)
            nK_Mat := nKol := nSum := 0
            @ 03,01 get nK_Mat pict "99999" valid VedMat(@nK_Mat,03,37)
            read
            if LastKey() == K_ESC ; Exit ; End
            nKSchet := S_Mat->KSchet
            @ 03,07 say nKSchet pict "99.99"
            @ 03,13 get nKol pict "999999.999" //valid nKol > 0
            @ 03,24 get nSum pict "99999999.99" //valid nSum > 0
            read
            if LastKey() == K_ESC ; break ; End
            if !M_Append(20,"OstMat") ; break ; End
            OstMat->K_Mat   := nK_Mat
            OstMat->KSchet  := nKSchet
            OstMat->Kol     := nKol
            OstMat->Sum     := nSum
            OstMat->(DbUnlock())
            nCena := Round(nSum/nKol,ROUND_CENA)
            if nRegim == 1 .and. nCena > S_Mat->Cena .and. M_Rlock(20,"S_Mat")
               S_Mat->Cena := nCena
               S_Mat->(DbUnlock())
            End
           End
           SetCursor(0)
           RestScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1,nKey)
           OstMat->(DbGoTop())
           FreshOrder(tb)
       case nKey == K_F5  // Корретировка
           tb:DeHilite()
           nKol  := OstMat->Kol
           nSum  := OstMat->Sum
           SetCursor(1)
           nKey := SaveScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1)
           @ MaxRow()-1,01 say padc("Корректируйте данные",MaxCol()-1) color sset[15]
           BEGIN SEQUENCE
           @ nRow,13 get nKol pict "999999.999" //valid nKol > 0
           @ nRow,24 get nSum pict "99999999.99" //valid nSum > 0
           read
           if LastKey() == K_ESC ; break ; End
           if !M_RLock(20,"OstMat") ; break ; End
           OstMat->Kol     := nKol
           OstMat->Sum     := nSum
           OstMat->(DbUnlock())
           nCena := Round(nSum/nKol,ROUND_CENA)
           if nRegim == 1 .and. nCena > S_Mat->Cena .and. M_Rlock(20,"S_Mat")
             S_Mat->Cena := nCena
             S_Mat->(DbUnlock())
           End
           END SEQUENCE
           SetCursor(0)
           RestScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1,nKey)
           FreshOrder(tb)
       other
           ApplyKey(nkey,tb)
    end
   end
End
S_wCloseSl(S_RanDom()%22+1)
END SEQUENCE
SetColor(ColorOld)
SetCursor(SursorOld)
DbCloseAll()
Return ( Nil )
//////////////////////////////////////////////////////////////////////////
Function Spisanie()
Local dDataRas := sset[SSET_DATA], nLastRec, nRecno, dDataS, i,j

BEGIN SEQUENCE
if !OpenDBF_(sset[SSET_BAZA]+"S_Mat")  ; break ; End
if !OpenDBF_(sset[SSET_BAZA]+"Akt")    ; break ; End
if !OpenDBF_(sset[SSET_BAZA]+"OstMatM") ; break ; End
Set Relation to str(K_Mat,5) into S_MAT
nRecno := SetColor(sset[32]+","+sset[2]+",,,"+sset[32])
nLastRec := SetCursor(1)
S_Open_M(12,38,14,65,sset[32],sset[2])
@ 01,01 say "Укажите дату" get dDataRas Pict "@d" valid !empty(dDataRas)
read
S_wCloseSl(S_RanDom()%22+1)
SetColor(nRecno)
SetCursor(nLastRec)
if lastkey()==K_ESC ; break ; End
nLastRec := OstMatM->(LastRec())
S_Line_N(18,04,65,nLastRec,1)
@ 01,06 say "Ожидайте..."
@ 01,42 say "Формирую данные "
nRecno := "[ По окончании будет подан звуковой сигнал ]"
@ 00,(MaxCol()-len(nRecno))/2 say nRecno
nRecno := 0
OstMatM->(DbGoTop())
While !OstMatM->(eof())
  if S_Mat->Pr == 1
    i := int(S_Mat->SrNos)
    j := (S_Mat->SrNos - i)*100
    dDataS := S_AddMon(OstMatM->DataP,i*12+j)
    if dDataS <= dDataRas .and. M_Append(20,"Akt")
       Akt->K_Mat   := OstMatM->K_Mat
       Akt->TabN    := OstMatM->TabN
       Akt->KSchet  := OstMatM->KSchet
       Akt->Kol     := OstMatM->Kol
       Akt->Sum     := OstMatM->Sum
       Akt->Ksp     := OstMatM->Ksp
       Akt->(DbUnlock())
    End
  End
  S_Line_N(18,04,65,nLastRec,++nRecno)
  OstMatM->(DbSkip(1))
End
S_Line_N()
My_Char()
END
DbCloseAll()
Return ( Nil )
/////////////////////////////////////////////////////////////////////////
Function CloseMes()  // закрытие месяца
Local nLastRec, nRecno

if !File(sset[SSET_BAZA]+"OstNewMat.Dbf") .or. !File(sset[SSET_BAZA]+"OstNemMat.Dbf")
  S_Err({02,"Вы не сформировали оборотную ведомость",;
            "% Нажмите Enter для продолжения;"})
  Return ( Nil )
End
if S_Err({02,,"Вы действительно желаите сделать",;
              " закрытие месяца "+S_cMonth(sset[SSET_DATA]),;
              " и не пожалеите об этом",;
              "%    Нет   ;   Да  ;"}) == 1
  Return ( Nil )
End
BEGIN SEQUENCE
if !OpenDbf_(sset[SSET_BAZA]+"Akt",.t.)    ; break ; End
if !OpenDbf_(sset[SSET_BAZA]+"Prixod",.t.) ; break ; End
if !OpenDbf_(sset[SSET_BAZA]+"Rasxod",.t.) ; break ; End
DbSelectArea("Prixod")
__DbZap()
Reindex
DbSelectArea("Rasxod")
__DbZap()
Reindex
DbSelectArea("Akt")
__DbZap()
Reindex
ferase(sset[SSET_BAZA]+"OstMat.dbf")
ferase(sset[SSET_BAZA]+"OstMat.ntx")
nRecno := 0
if S_FileMove( sset[SSET_BAZA]+"OstNewMat.Dbf", sset[SSET_BAZA]+"OstMat.Dbf") == 0 ;
   .and. OpenDbf_(sset[SSET_BAZA]+"OstMat",.t.)
   DbSelectArea("OstMat")
   Reindex
   nRecno++
End
ferase(sset[SSET_BAZA]+"OstMatM.dbf")
ferase(sset[SSET_BAZA]+"OstMatM.ntx")
if S_FileMove( sset[SSET_BAZA]+"OstNemMat.Dbf", sset[SSET_BAZA]+"OstMatM.Dbf") == 0 ;
   .and. OpenDbf_(sset[SSET_BAZA]+"OstMatM",.t.)
   DbSelectArea("OstMatM")
   Reindex
   nRecno++
End
if nRecno == 2
  S_Err({"Ok!"," все готово ","% нажмите ENTER для продолжения ;"})
End
END SEQUENCE
DbCloseAll()
Return ( Nil )
//////////////////////////////////////////////////////////////////////////
Function VedRasxM()  // Ведение расхода МОЛ
Local tb, ColorOld, SursorOld, nKey, nRow, GetList := {}
Local nNnak, nK_Mat, nEnt, nKol, nSum, nCena

ColorOld := SetColor(COLOR_BAZA)
SursorOld := SetCursor(0)
if !file(sset[SSET_DIRTN]+"Superlis.Dbf")
  My_Char()
  S_Err({"Отсутствует справочник работающих"})
  Return ( Nil )
End
if !file(sset[SSET_DIRTN]+"Ssp.Dbf")
  My_Char()
  S_Err({"Отсутствует справочник подразделений"})
  Return ( Nil )
End
BEGIN SEQUENCE
OpenTn()
OpenKsp()
if !OpenDbf_(sset[SSET_BAZA]+"S_Chet") ;  break ; End
if !OpenDbf_(sset[SSET_BAZA]+"S_Mat")  ;  break ; End
if !OpenDbf_(sset[SSET_BAZA]+"Akt")    ;  break ; End
Set relation to str(K_Mat,5) into S_Mat,;
             to TabN into TN
DbSelectArea("Akt")
S_Open_M(02,01,22,76,,sset[2])
@ 01,01 say "K.мат Таб.N  К-во        Сумма     N  нак  к.сч    Наименование"
@ 02,01 say Repl([─],MaxCol()-1)
@ MaxRow()-3,01 say Repl([─],MaxCol()-1)
@ MaxRow()-2,01 say "Фамилия МОЛ"
@ MaxRow()-2,34 say "Подразд.  "
@ MaxRow()-2,49 say "Счет"
@ MaxRow()-1,01 say padc("3удалить 4регистрировать 5корректировать ",MaxCol()-1) color sset[5]
tb := TBrowseDb(03,01,MaxRow()-4,MaxCol()-1)
tb:AddColumn(TbColumnNew("" ,{|| str(Akt->K_Mat,5)+" "+Akt->TabN+" "+;
   str(Akt->Kol,10,3)+" "+str(Akt->Sum,11,2)+" "+str(Akt->Nnak,6)+" "+;
   str(Akt->KSChet,5,2)+" "+S_Mat->Naim } ))
Akt->(DbGoTop())
While ( .t. )
   nKey := 0
   While ( !tb:Stabilize() )
     if ( nKey := m_inkey() ) != 0 ; exit ; end
   end
   nRow := Row()
   @ MaxRow()-2,13 say Tn->Fio
   @ MaxRow()-2,43 say Akt->Ksp
   @ MaxRow()-2,54 say Akt->Schet pict "99.99"
   if nKey == 0 ; nKey := m_inkey(0)  ; end
   if nKey == K_ESC ; exit ; end
   if tb:Stable
    do case
       case nKey == K_F3  // Удаление
           if Akt->(Recno()) # 0 .and. S_Err({S_wRow()+1,S_wCol()+2,,;
             "Вы действительно","желаите удалить запись",;
             "и не пожалеите об этом?","% Да ; Нет ;"}) == 1 .and. M_Rlock(20,"Akt")
                 Akt->(DbDelete())
                 Akt->(DbUnlock())
                 Akt->(DbSkip(1))
                 if Akt->(eof()) ; Akt->(DbGoBottom()) ; end
           end
           FreshOrder(tb)
       case nKey == K_F4  // Регистрация
           @ 03,01 say padc(" ",MaxCol()-1)
           SetCursor(1)
           nKey := SaveScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1)
           @ MaxRow()-1,01 say padc("Регистрируте данные",MaxCol()-1) color sset[15]
           While ( .t. )
            Scroll(03,01,MaxRow()-4,MaxCol()-1,-1)
            @ MaxRow()-2,13 say space(20)
            nK_Mat := nKol := nSum := nNnak := nSchet := 0
            nTabn  := space(6)
            @ 03,01 get nK_Mat pict "99999" valid VedMat(@nK_Mat,03,50)
            read
            if LastKey() == K_ESC ; Exit ; End
            nKSchet := S_Mat->KSchet
            @ 03,44 say nKSchet pict "99.99"
            @ 03,07 get nTabN valid TabN<>"******" .and. VedTabN(@nTabN,MaxRow()-2,13)
            @ 03,14 get nKol pict "999999.999" //valid nKol > 0
            read
            if LastKey() == K_ESC ; break ; End
            nSum := Round(nKol*S_Mat->Cena,ROUND_S14)
            @ 03,25 get nSum pict "99999999.99" //valid nSum > 0
            @ 03,37 get nNnak pict "999999"
            read
            if LastKey() == K_ESC ; break ; End
            cKsp := Tn->Ksp
            @ MaxRow()-2,43 get cKsp
            read
            if LastKey() == K_ESC ; break ; End
            @ MaxRow()-2,54 get nSchet pict "99.99"
            read
            if LastKey() == K_ESC ; break ; End
            if !M_Append(20,"Akt") ; break ; End
            Akt->K_Mat   := nK_Mat
            Akt->TabN    := nTabN
            Akt->Nnak    := nNnak
            Akt->KSchet  := nKSchet
            Akt->Schet   := nSchet
            Akt->Kol     := nKol
            Akt->Sum     := nSum
            Akt->Ksp     := cKsp
            Akt->(DbUnlock())
            nCena := Round(nSum/nKol,ROUND_CENA)
//            if nCena > S_Mat->Cena .and. M_Rlock(20,"S_Mat")
//               S_Mat->Cena := nCena
//               S_Mat->(DbUnlock())
//            End
           End
           SetCursor(0)
           RestScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1,nKey)
           Akt->(DbGoTop())
           FreshOrder(tb)
       case nKey == K_F5  // Корретировка
           tb:DeHilite()
           nKol  := Akt->Kol
           nSum  := Akt->Sum
           nNnak := Akt->Nnak
           nTabN := Akt->TabN
           nSchet := Akt->Schet
           SetCursor(1)
           nKey := SaveScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1)
           @ MaxRow()-1,01 say padc("Корректируйте данные",MaxCol()-1) color sset[15]
           BEGIN SEQUENCE
           @ nRow,07 get nTabN valid TabN<>"******" .and. VedTabN(@nTabN,MaxRow()-2,13)
           @ nRow,14 get nKol pict "999999.999" //valid nKol > 0
           @ nRow,25 get nSum pict "99999999.99" //valid nSum > 0
           @ nRow,37 get nNnak pict "999999"
           read
           if LastKey() == K_ESC ; break ; End
           cKsp := Tn->Ksp
           @ MaxRow()-2,43 get cKsp
           read
           if LastKey() == K_ESC ; break ; End
           @ MaxRow()-2,54 get nSchet pict "99.99"
           read
           if LastKey() == K_ESC ; break ; End
           if !M_RLock(20,"Akt") ; break ; End
           Akt->Nnak    := nNnak
           Akt->Kol     := nKol
           Akt->Sum     := nSum
           Akt->TabN    := nTabN
           Akt->Ksp     := cKsp
           Akt->Schet   := nSchet
           Akt->(DbUnlock())
//           nCena := Round(nSum/nKol,ROUND_CENA)
//           if nCena > S_Mat->Cena .and. M_Rlock(20,"S_Mat")
//             S_Mat->Cena := nCena
//             S_Mat->(DbUnlock())
//           End
           END SEQUENCE
           SetCursor(0)
           RestScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1,nKey)
           FreshOrder(tb)
       other
           ApplyKey(nkey,tb)
    end
   end
End
S_wCloseSl(S_RanDom()%22+1)
END SEQUENCE
SetColor(ColorOld)
SetCursor(SursorOld)
DbCloseAll()
Return ( Nil )
///////////////////////////////////////////////////////////////////////////
Function VedOstM()  // Ведение остатков МОЛ
Local tb, ColorOld, SursorOld, nKey, nRow, GetList := {}
Local nNnak, nK_Mat, nKol, nSum, nRegim, nCena, nTabN

ColorOld := SetColor(COLOR_BAZA)
SursorOld := SetCursor(0)
if !file(sset[SSET_DIRTN]+"Superlis.Dbf")
  My_Char()
  S_Err({"Отсутствует справочник работающих"})
  Return ( Nil )
End
if !file(sset[SSET_DIRTN]+"Ssp.Dbf")
  My_Char()
  S_Err({"Отсутствует справочник подразделений"})
  Return ( Nil )
End
BEGIN SEQUENCE
OpenTn()
OpenKsp()
if !OpenDbf_(sset[SSET_BAZA]+"S_Chet") ;  break ; End
if !OpenDbf_(sset[SSET_BAZA]+"S_Mat")  ;  break ; End
if !OpenDbf_(sset[SSET_BAZA]+"OstMatM") ;  break ; End
Set relation to str(K_Mat,5) into S_Mat,;
             to TabN into TN
DbSelectArea("OstMatM")
S_Open_M(02,01,22,71,,sset[2])
@ 01,01 say "К.мат  к.сч  Таб.N   к-во       сумма       Наименование"
@ 02,01 say Repl([─],MaxCol()-1)
@ MaxRow()-3,01 say Repl([─],MaxCol()-1)
@ MaxRow()-2,01 say "Фамилия МОЛ"
@ MaxRow()-2,34 say "Подразд."
@ MaxRow()-2,49 say "Дата/пол."
@ MaxRow()-1,01 say padc("3удалить 4регистр 5коррект 6удалНУЛИ ",MaxCol()-1) color sset[5]
tb := TBrowseDb(03,01,MaxRow()-4,MaxCol()-1)
tb:AddColumn(TbColumnNew("" ,{|| str(OstMatM->K_Mat,5)+" "+str(OstMatM->KSchet,5,2)+" "+;
   OstMatM->TabN+" "+str(OstMatM->Kol,10,3)+" "+str(OstMatM->Sum,11,2)+" "+;
   S_Mat->Naim+"  " } ))
OstMatM->(DbGoTop())
While ( !tb:Stabilize() ) ; End
//nRegim := S_Err({"Укажите режим корректировки цены?",;
//                 "%  Корректировать  ;  Не корректировать  ;"})
While ( .t. )
   nKey := 0
   While ( !tb:Stabilize() )
     if ( nKey := m_inkey() ) != 0 ; exit ; end
   end
   nRow := Row()
   @ MaxRow()-2,13 say Tn->Fio
   @ MaxRow()-2,43 say OstMatM->Ksp
   @ MaxRow()-2,59 say OstMatM->DataP pict "@d"
   if nKey == 0 ; nKey := m_inkey(0)  ; end
   if nKey == K_ESC ; exit ; end
   if tb:Stable
    do case
       case nKey == K_F3  // Удаление
           if OstMatM->(Recno()) # 0 .and. S_Err({S_wRow()+1,S_wCol()+2,,;
             "Вы действительно","желаите удалить запись",;
             "и не пожалеите об этом?","% Да ; Нет ;"}) == 1 .and. M_Rlock(20,"OstMatM")
                 OstMatM->(DbDelete())
                 OstMatM->(DbUnlock())
                 OstMatM->(DbSkip(1))
                 if OstMatM->(eof()) ; OstMatM->(DbGoBottom()) ; end
           end
           FreshOrder(tb)
       case nKey == K_F6  // Удалить нулевые остатки
           if S_Err({S_wRow()+1,S_wCol()+2,,;
             "Вы действительно","желаите удалить нулевые остатки",;
             "и не пожалеите об этом?","% Да ; Нет ;"}) == 1
              S_Sys({"Минутку"})
              OstMatM->(DbGoTop())
              While !OstMatM->(eof())
                if OstMatM->Kol == 0 .and. OstMatM->Sum == 0 .and. M_Rlock(20,"OstMatM")
                    OstMatM->(DbDelete())
                    OstMatM->(DbUnlock())
                 End
                 OstMatM->(DbSkip(1))
              End
              S_Sys()
              OstMatM->(DbGoTop())
           end
           FreshOrder(tb)
       case nKey == K_F4  // Регистрация
           @ 03,01 say padc(" ",MaxCol()-1)
           SetCursor(1)
           nKey := SaveScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1)
           @ MaxRow()-1,01 say padc("Регистрируте данные",MaxCol()-1) color sset[15]
           While ( .t. )
            Scroll(03,01,MaxRow()-4,MaxCol()-1,-1)
            nK_Mat := nKol := nSum := 0
            nTabN := space(6)
            @ 03,01 get nK_Mat pict "99999" valid VedMat(@nK_Mat,03,43)
            read
            if LastKey() == K_ESC ; Exit ; End
            nKSchet := S_Mat->KSchet
            @ 03,07 say nKSchet pict "99.99"
            @ 03,13 get nTabN valid TabN<>"******" .and. VedTabN(@nTabN,MaxRow()-2,13)
            @ 03,20 get nKol pict "999999.999" //valid nKol > 0
            read
            if LastKey() == K_ESC ; break ; End
            nSum := Round(nKol*S_Mat->Cena,ROUND_S14)
            @ 03,31 get nSum pict "99999999.99" //valid nSum > 0
            read
            if LastKey() == K_ESC ; break ; End
            cKsp := Tn->Ksp
            dDataP := sset[SSET_DATA]
            @ MaxRow()-2,43 get cKsp
            @ MaxRow()-2,59 get dDataP pict "@d" valid !Empty(dDataP)
            read
            if LastKey() == K_ESC ; break ; End
            if !M_Append(20,"OstMatM") ; break ; End
            OstMatM->K_Mat   := nK_Mat
            OstMatM->KSchet  := nKSchet
            OstMatM->Kol     := nKol
            OstMatM->Sum     := nSum
            OstMatM->TabN    := nTabN
            OstMatM->Ksp     := cKsp
            OstMatM->DataP   := dDataP
            OstMatM->(DbUnlock())
//            nCena := Round(nSum/nKol,ROUND_CENA)
//            if nRegim == 1 .and. nCena > S_Mat->Cena .and. M_Rlock(20,"S_Mat")
//               S_Mat->Cena := nCena
//               S_Mat->(DbUnlock())
//            End
           End
           SetCursor(0)
           RestScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1,nKey)
           OstMatM->(DbGoTop())
           FreshOrder(tb)
       case nKey == K_F5  // Корретировка
           tb:DeHilite()
           nKol  := OstMatM->Kol
           nSum  := OstMatM->Sum
           nTabN := OstMatM->TabN
           dDataP:= OstMatM->DataP
           SetCursor(1)
           nKey := SaveScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1)
           @ MaxRow()-1,01 say padc("Корректируйте данные",MaxCol()-1) color sset[15]
           BEGIN SEQUENCE
           @ nRow,13 get nTabN valid TabN<>"******" .and. VedTabN(@nTabN,MaxRow()-2,13)
           @ nRow,20 get nKol pict "999999.999" //valid nKol > 0
           @ nRow,31 get nSum pict "99999999.99" //valid nSum > 0
           read
           if LastKey() == K_ESC ; break ; End
           cKsp := Tn->Ksp
           @ MaxRow()-2,43 get cKsp
           @ MaxRow()-2,59 get dDataP pict "@d" valid !Empty(dDataP)
           read
           if LastKey() == K_ESC ; break ; End
           if !M_RLock(20,"OstMatM") ; break ; End
           OstMatM->Kol     := nKol
           OstMatM->Sum     := nSum
           OstMatM->TabN    := nTabN
           OstMatM->Ksp     := cKsp
           OstMatM->DataP   := dDataP
           OstMatM->(DbUnlock())
//           nCena := Round(nSum/nKol,ROUND_CENA)
//           if nRegim == 1 .and. nCena > S_Mat->Cena .and. M_Rlock(20,"S_Mat")
//             S_Mat->Cena := nCena
//             S_Mat->(DbUnlock())
//           End
           END SEQUENCE
           SetCursor(0)
           RestScreen(MaxRow()-1,01,MaxRow()-1,MaxCol()-1,nKey)
           FreshOrder(tb)
       other
           ApplyKey(nkey,tb)
    end
   end
End
S_wCloseSl(S_RanDom()%22+1)
END SEQUENCE
SetColor(ColorOld)
SetCursor(SursorOld)
DbCloseAll()
Return ( Nil )
//////////////////////////////////////////////////////////////////////////

