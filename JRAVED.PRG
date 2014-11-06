#include "Mater.ch"
#include "Inkey.ch"
#Define NOM_KEY 30
#Define ROUND_CENA 2
#Define ROUND_S14  2
/////////////////////////////////////////////////////////////////////////////
function VedomPrix() // Ведомость Прихода
Local oSum, kSum, fSum, nRecno, nLastRec, nEnt, nNpp
Local oFile := sset[SSET_WORK]+"VedPrix.txt"
Private nLen := 69, nPage := 0, nLine := 70, iPage := 0
Private dDataRas := sset[SSET_DATA], nKSchet

BEGIN SEQUENCE
if !OpenDbf_(sset[SSET_BAZA]+"S_Ent")  ; break ; End
if !OpenDbf_(sset[SSET_BAZA]+"S_MAT")  ; break ; End
if !OpenDbf_(sset[SSET_BAZA]+"Prixod") ; break ; End
Set Relation to str(K_Mat,5) into S_Mat
nLastRec := Prixod->(LastRec())
S_Line_N(18,04,65,nLastRec,1)
@ 01,06 say "Ожидайте..."
@ 01,42 say "Формирую ведомость "
nRecno := "[ По окончании будет подан звуковой сигнал ]"
@ 00,(MaxCol()-len(nRecno))/2 say nRecno
nRecno := fSum := 0
Set(20,"PRINT")
Set(24,oFile)
Prixod->(DbGoTop())
While ( !Prixod->(eof()) )
  nKSchet := Prixod->KSchet
  kSum    := 0
  nNpp    := 0
  iPage   := nLine := 0
  While ( nKSchet == Prixod->KSchet .and. !Prixod->(eof()) )
    nEnt := Prixod->Ent
    oSum := 0
    S_Ent->(DbSeek(str(nEnt,4)))
    PutPrix( padc(str(nEnt,4)+" "+alltrim(S_Ent->Naim),nLen) )
    While ( nEnt == Prixod->Ent .and. nKSchet == Prixod->KSchet .and. !Prixod->(eof()) )
       PutPrix( str(++nNpp,3)+" "+str(Prixod->K_Mat,5)+" "+S_Mat->Naim+" "+;
         S_Mat->EdIzm+" "+str(Prixod->Nnak,6)+" "+str(Prixod->Kol,9,3)+" "+;
         str(Prixod->Sum,11,2) )
       oSum += Prixod->Sum
       S_Line_N(18,04,65,nLastRec,++nRecno)
       Prixod->(DbSkip(1))
    End
    kSum += oSum
    PutPrix( repl("-",nLen) )
    PutPrix( padl("Итого по организации      "+str(oSum,11,2),nLen) )
  End
  fSum += kSum
  PutPrix( repl("-",nLen) )
  PutPrix( padl("Итого по дебету  счета    "+str(kSum,11,2),nLen) )
  PutPrix( " " )
  PutPrix( " " )
  PutPrix( " " )
End
@ prow()+1,00 say repl("-",nLen)
@ prow()+1,00 say "Итого по приходу"
@ prow(),58   say str(fSum,11,2)
nLine += 2
For i := nLine to 66
   @ prow()+1,00 say ""
Next
@ prow()+1,00 say ""
My_Char()
S_Line_N()
Set(24,"")
Set(20,"SCREEN")
ShowPrn(oFile," Ведомость ",74)
END SEQUENCE
DbCloseAll()
fErase(oFile)
Return ( Nil )
///////////////////////////////////////////////////////////////////////////
Static Function PutPrix(cLine)
Local i
if iPage == 0 .or. nLine > 64
  if nLine > 64
     For i := nLine to 66
        @ prow()+1,00 say ""
     Next
     nLine := 0
  End
  if iPage == 0
     @ prow()+1,00 say padc("Ведомость прихода по дебету счета "+str(nKSchet,5,2),nLen)
     @ prow()+1,00 say padc(" за "+S_cMonth(dDataRas)+" месяц "+str(year(dDataRas),4)+" год",nLen)
     @ prow()+1,00 say padc(" ",nLen)
     nLine := 3
  End
  @ prow()+1,00 say padr("     Лист# "+str(++nPage,3),nLen)
  @ prow()+1,00 say repl("-",nLen)
  @ prow()+1,00 say "Nпп|к.мат|      наименование       |едиз| N нак|  к-во   |  сумма    "
  @ prow()+1,00 say repl("-",nLen)
  nLine += 4
  iPage++
End
@ prow()+1,00 say cLine
nLine++
Return ( Nil )

////////////////////////////////////////////////////////////////////////////
Function VedomRasx() // Ведомость расхода
Local nKSchet := 05.01, dDataRas := sset[SSET_DATA], Arr_Shet, Arr_Chet, cLine
Local i, j, Pos_Kol, Pos_Sum, nLastRec, nRecno, nPos, cCh, oFile, Itog, nNpp
Private nLine, nPage := 0, NoPage := 0

BEGIN SEQUENCE
if !OpenDBF_(sset[SSET_BAZA]+"S_Mat")  ; break ; End
if !OpenDBF_(sset[SSET_BAZA]+"Rasxod") ; break ; End
fErase(sset[SSET_WORK]+"Work.dbf")
fErase(sset[SSET_WORK]+"Work.Ntx")
DelRas()
Arr_Shet := { {"K_Mat", "N",05,00},;   // код материала
              {"Naim",  "C",30,00},;   // наименование
              {"ItogK", "N",09,03},;   // итого КОЛИЧЕСТВО
              {"ItogS", "N",11,02} }   // итого Сумма
for i := 1 to NOM_KEY  //  Реквизиты по ДЕБЕТУ
  aadd(Arr_Shet,{"K"+alltrim(str(i,2)),"N",09,03}) // кол-во
next
for i := 1 to NOM_KEY  //  Реквизиты по ДЕБЕТУ
  aadd(Arr_Shet,{"S"+alltrim(str(i,2)),"N",11,02}) // сумма
next
Dbcreate(sset[SSET_WORK]+"WORK",Arr_Shet)
use (sset[SSET_WORK]+"WORK") new
Index on str(K_Mat,5) to (sset[SSET_WORK]+"WORK")
S_Open_NW(18,02,20,15)
@ 01,02 say "Счет" get nKSchet pict "99.99" valid !Empty(nKSchet)
read
S_wCloseSl(S_RanDom()%22+1)
if LastKey() == K_ESC ; break ; End
Pos_Kol := 4            // Позиция КОЛИЧЕСТВА в базе
Pos_Sum := 4 + NOM_KEY  // Позиция СУММА в базе
Arr_Shet:={} // счета дебетовые
nLastRec := Rasxod->(LastRec())
S_Line_N(18,04,65,nLastRec,1)
@ 01,06 say "Ожидайте..."
@ 01,42 say "Формирую данные "
nRecno := "[ По окончании будет подан звуковой сигнал ]"
@ 00,(MaxCol()-len(nRecno))/2 say nRecno
nRecno := 0
Rasxod->(DbGoTop())
While !Rasxod->(eof())
  if Rasxod->KSchet == nKSchet
    if !Work->(Dbseek(str(Rasxod->K_Mat,5)))
        Work->(DbAppend())
        Work->K_Mat  := Rasxod->K_Mat
        S_Mat->(DbSeek(str(Rasxod->K_Mat,5)))
        Work->Naim   := S_Mat->Naim+" "+S_Mat->EdIzm
    End
    if ( nPos := ascan(Arr_Shet,{|x| x[1] == Rasxod->DSchet }) ) == 0
        nPos := len(Arr_Shet) + 1
        aadd(Arr_Shet,{Rasxod->DSchet,nPos })
    End
    if nPos > NOM_KEY
       S_ERR({"Не могу продолжать работу","Обратитесь к авторам",;
              "% Нажмите Enter для продолжения;"})
       break
    End
    i := Pos_Sum + nPos
    nSumma := Work->(FieldGet(i))
    Work->(FieldPut(i,nSumma+Rasxod->Sum))
    i := Pos_Kol + nPos
    nKolvo := Work->(FieldGet(i))
    Work->(FieldPut(i,nKolvo+Rasxod->Kol))
    Work->ItogK += Rasxod->Kol
    Work->ItogS += Rasxod->Sum
  End
  S_Line_N(18,04,65,nLastRec,++nRecno)
  Rasxod->(Dbskip(1))
End
S_Line_N()
Work->(DbGotop())
if Work->(eof())
  S_Err({04,"Отсутствуют данные","%Нажмите Enter для продолжения;"})
  break
End
//         ВСЕ ГОТОВО ----- Формируем наконец-то ведомость
Arr_Shet := aSort(Arr_Shet,,,{|x,y| x[1]<y[1] })
nPos := Len(Arr_Shet)
Arr_Chet := { ;
   { {|x| str(Work->K_Mat,5)},{|x| 0 },1,5,0,{": код ",;
                                              ": мате",;
                                              ": риал"} },;
   { {|x| Work->Naim },{|x| 0 },2,30,0,{":                        : ед ",;
                                        ":    Наименование        :изме",;
                                        ":                        :рени"} } }
for i := 1 to nPos              // Заносим дебетовые счета
 j := Pos_Kol + Arr_Shet[i][2]  // номер реквизита
 aadd(Arr_Chet,{ {|x| str(Work->(FieldGet(x)),9,3) },;
                 {|x| 0 },j,9,3,;
                 {  ":  дебет  ",;
                    ":---------",;
                    ": кол-во  "} } )
 j := Pos_Sum + Arr_Shet[i][2]  // номер реквизита
 nLine := padc(str(Arr_Shet[i][1],5,2),12)
 aadd(Arr_Chet,{ {|x| str(Work->(FieldGet(x)),11,2) },;
                 {|x| Work->(FieldGet(x)) },j,11,0,;
                 {  nLine,;
                    "------------",;
                    ":  сумма    "} } )
next
aadd(Arr_Chet,{ {|x| str(Work->ItogK,9,3) },{|x| 0 },3,9,3,;
                          {": Итого   ",;
                           ":---------",;
                           ": кол-во  "} } )
aadd(Arr_Chet,{ {|x| str(Work->ItogS,11,2)  },{|x| Work->ItogS },4,11,0,;
                          {"  расхода   ",;
                           "------------",;
                           ":  сумма    "} } )
Arr_Shet := Nil  // Они уже не нужны
nLine:= 18     // ????????????????????????????????????????????
cCh  := chr(18)
if ( nPos := Len(Arr_Chet) ) > 6
  cCh := chr(15)  // нужно сжимать
End
j := min(nLine, nPos)
oFile := {}
i := 1
While ( i < nPos )
  aadd(oFile,{Nil,i,j})
  i := j + 1
  j += ( nLine + 1 )
  j := Min(j,nPos)
End
if i == nPos
  aadd(oFile,{Nil,nPos,nPos})
End
for i := 1 to len(oFile)
  oFile[i][1] := oFileNew()
  oFile[i][1]:Open(sset[SSET_WORK]+"mrasx"+alltrim(str(i,2))+".ved")
next
Itog := array(nPos)
nPos := Len(oFile)
afill(Itog,0)
//  Печатаем шапку  в первую часть
oFile[1][1]:WriteLn(cCh+"  Ведомость расхода по кредиту счета "+str(nKSchet,5,2))
oFile[1][1]:WriteLn("     за "+S_cMonth(dDataRas)+" месяц "+str(year(dDataRas),4)+" г.")
oFile[1][1]:WriteLn("  ")
for i := 2 to nPos // и в остальные части
  oFile[i][1]:WriteLn(cCh+" ")
  oFile[i][1]:WriteLn(" ")
  oFile[i][1]:WriteLn(" ")
next
nLine := 3  // количество строк
nNpp  := 0  // N по порядку
nLastRec := Work->(LastRec())
S_Line_N(18,04,65,nLastRec,1)
@ 01,06 say "Ожидайте..."
@ 01,42 say "Формирую ведомость "
nRecno := "[ По окончании будет подан звуковой сигнал ]"
@ 00,(MaxCol()-len(nRecno))/2 say nRecno
nRecno := 0
Work->(DbGoTop())
While ( !Work->(eof()) )
  RasxShapka(oFile,Arr_Chet)
  Pos_Kol := str(++nNpp,3)
  for i := 1 to nPos
    cLine := Pos_Kol
    for j := oFile[i][2] to oFile[i][3]
      cLine   += ( " "+eval(Arr_Chet[j][1],Arr_Chet[j][3]) )  // что в строку
      Itog[j] += eval(Arr_Chet[j][2],Arr_Chet[j][3])  // считаем итог
    next
    oFile[i][1]:WriteLn(cLine)  // печатаем строку
  next
  nLine++  // увеличиваем количество строк
  S_Line_N(18,04,65,nLastRec,++nRecno)
  Work->(Dbskip(1))
End
// подводим итог к печатному виду
for i := 3 to len(Itog)
    if !Empty(Itog[i])
       Itog[i] := str(Itog[i],Arr_Chet[i][4],2)  //Arr_Chet[i][5])
    else
       Itog[i] := space(Arr_Chet[i][4])
    End
next
Itog[1] := "Итого"     // итог по коду материала
Itog[2] := space(30)   // итого по наименованию
// печатаем строку ================
for i := 1 to len(oFile)
    cLine := "===" // N по порядку
    for j := oFile[i][2] to oFile[i][3]
      cLine += "="+repl("=",Arr_Chet[j][4])
    next
    oFile[i][1]:WriteLn(cLine)
next
// Печать итогов
for i := 1 to nPos
  cLine := "   " // N по порядку
  for j := oFile[i][2] to oFile[i][3]
    cLine += " "+Itog[j]
  next
  oFile[i][1]:WriteLn(cLine)
next
// Закрываем файлы
for i := 1 to len(oFile)
  oFile[i][1]:WriteLn(chr(18))
  oFile[i][1]:close()
next
S_Line_N()
My_Char()
PrnVedRas()
END SEQUENCE
DbCloseAll()
fErase(sset[SSET_WORK]+"Work.dbf")
fErase(sset[SSET_WORK]+"Work.Ntx")
DelRas()
Return ( Nil )
///////////////////////////////////////////////////////////////////////////
static function RasxShapka(oFile,Arr_Chet) // печать шапки
Local i,j,cLine1,cLine2,cLine3,cLinep
if nLine > 58 .or. nPage == 0
  if nPage <> 0
    for i := 1 to len(oFile)
       for j := nLine to 60
          oFile[i][1]:WriteLn(" ")
       next
    next
    nLine := 0
  End
  nPage++
  for i := 1 to len(oFile)
    oFile[i][1]:WriteLn("        Лист# "+str(nPage,3)+" Ф-"+alltrim(str(i,2)) )
    cLinep := "---"
    cLine1 := " N "
    cline2 := "п/п"
    cLine3 := "   "
    for j := oFile[i][2] to oFile[i][3]
      cLinep += "-"+repl("-",Arr_Chet[j][4])
      cLine1 += Arr_Chet[j][6][1]
      cLine2 += Arr_Chet[j][6][2]
      cLine3 += Arr_Chet[j][6][3]
    next
    oFile[i][1]:WriteLn(cLinep)
    oFile[i][1]:WriteLn(cLine1)
    oFile[i][1]:WriteLn(cLine2)
    oFile[i][1]:WriteLn(cLine3)
    oFile[i][1]:WriteLn(cLinep)
  next
  nLine += 5
End
Return ( Nil )
/////////////////////////////////////////////////////////////////////////
function PrnVedRas() // вывод на экран и печать
Local KolVed := aDir(sset[SSET_WORK]+"mrasx*.ved"), FileVed, cFile
Private NomVed
if KolVed == 0
  S_Err({"Ведомость не сформирована"})
  Return ( Nil )
End
FileVed := array(KolVed)
aDir(sset[SSET_WORK]+"mrasx*.ved",FileVed)
While ( .t. )
   NomVed := 1
   S_Get({14,02,"Укажите номер фрагмента ведомости ("+alltrim(str(KolVed,2))+;
                ")","NomVed","99"})
   if LastKey() == K_ESC ; exit ; End
   if NomVed <= 0 .or. NomVed > KolVed ; loop ; end
   cFile := sset[SSET_WORK]+"mRasx"+alltrim(str(NomVed,2))+".ved"
   ShowPrn(cFile,"Фрагмент ведомости",77)
End
Return ( Nil )
///////////////////////////////////////////////////////////////////////////
Static function DelRas() // удаление частей ведомости
Local KolVed := aDir(sset[SSET_WORK]+"mrasx*.ved"), FileVed, i
FileVed := array(KolVed)
aDir(sset[SSET_WORK]+"mrasx*.ved",FileVed)
for i := 1 to len(FileVed)
   fErase(sset[SSET_WORK]+"mRasx"+alltrim(str(i,2))+".ved")
End
Return ( Nil )
////////////////////////////////////////////////////////////////////////
Function VedomObor() // Ведомость оборотная
Local oFile := sset[SSET_WORK]+"MatObor.Ved", nLastRec, nRecno, nKolK
Local nSumP, nSumR, nSumN, nNpp, nS14, iS14, iKolK, iSumK, nSumK
Local nKSchet := 05.01, nCena, dDataRas := sset[SSET_DATA]
Private nLen, nPage := 0, nLine, iPage := 0

BEGIN SEQUENCE
if !OpenDBF_(sset[SSET_BAZA]+"S_Mat")  ; break ; End
if !OpenDBF_(sset[SSET_BAZA]+"Rasxod") ; break ; End
if !OpenDBF_(sset[SSET_BAZA]+"Prixod") ; break ; End
if !OpenDBF_(sset[SSET_BAZA]+"OstMat") ; break ; End
__DbCopyStru( (sset[SSET_BAZA]+"OstNewMat") )
use (sset[SSET_BAZA]+"OstNewMat") new alias OSTNEWMAT
fErase(sset[SSET_WORK]+"Work.dbf")
fErase(sset[SSET_WORK]+"Work.Ntx")
Dbcreate(sset[SSET_WORK]+"WORK",{ {"KSchet","N",05,02},;
                                  {"K_mat", "N",05,00},;
                                  {"KolN",  "N",10,03},;
                                  {"SumN",  "N",11,02},;
                                  {"KolP",  "N",10,03},;
                                  {"SumP",  "N",11,02},;
                                  {"KolR",  "N",10,03},;
                                  {"SumR",  "N",11,02}})
use (sset[SSET_WORK]+"WORK") new
Index on str(KSchet,5,2)+str(K_Mat,5) to (sset[SSET_WORK]+"WORK")
nLastRec := Rasxod->(LastRec()) + Rasxod->(LastRec()) + OstMat->(LastRec())
S_Line_N(18,04,65,nLastRec,1)
@ 01,06 say "Ожидайте..."
@ 01,42 say "Формирую данные "
nRecno := "[ По окончании будет подан звуковой сигнал ]"
@ 00,(MaxCol()-len(nRecno))/2 say nRecno
nRecno := 0
Rasxod->(DbGoTop())
While !Rasxod->(eof())
  if !Work->(Dbseek(str(Rasxod->KSchet,5,2)+str(Rasxod->K_Mat,5)))
      Work->(DbAppend())
      Work->K_Mat  := Rasxod->K_Mat
      Work->KSchet := Rasxod->KSchet
  End
  Work->SumR += Rasxod->Sum
  Work->KolR += Rasxod->Kol
  S_Line_N(18,04,65,nLastRec,++nRecno)
  Rasxod->(Dbskip(1))
End
Prixod->(DbGoTop())
While !Prixod->(eof())
  if !Work->(Dbseek(str(Prixod->KSchet,5,2)+str(Prixod->K_Mat,5)))
      Work->(DbAppend())
      Work->K_Mat  := Prixod->K_Mat
      Work->KSchet := Prixod->KSchet
  End
  Work->SumP += Prixod->Sum
  Work->KolP += Prixod->Kol
  S_Line_N(18,04,65,nLastRec,++nRecno)
  Prixod->(Dbskip(1))
End
OstMat->(DbGoTop())
While !OstMat->(eof())
  if !Work->(Dbseek(str(OstMat->KSchet,5,2)+str(OstMat->K_Mat,5)))
      Work->(DbAppend())
      Work->K_Mat  := OstMat->K_Mat
      Work->KSchet := OstMat->KSchet
  End
  Work->SumN += OstMat->Sum
  Work->KolN += OstMat->Kol
  S_Line_N(18,04,65,nLastRec,++nRecno)
  OstMat->(Dbskip(1))
End
DbSelectArea("Work")
Set Relation to str(K_Mat,5) into S_MAT
S_Line_N()
nLastRec := Work->(LastRec())
S_Line_N(18,04,65,nLastRec,1)
@ 01,06 say "Ожидайте..."
@ 01,42 say "Формирую ведомость "
nRecno := "[ По окончании будет подан звуковой сигнал ]"
@ 00,(MaxCol()-len(nRecno))/2 say nRecno
nRecno := 0
vSumP := vSumR := vSumN := vS14 := vSumK := vKolK := 0
Set(20,"PRINT")
Set(24,oFile)
nLen := 144
Work->(DbGoTop())
While ( !Work->(eof()) )
  nKSchet := Work->KSchet
  nSumP := nSumR := nSumN := nS14 := nSumK := nKolK := 0
  @ prow()+1,00 say padc("Оборотная ведомость счета "+str(nKSchet,5,2),nLen)
  @ prow()+1,00 say padc("за "+S_cMonth(dDataRas)+" месяц "+str(year(dDataRas),4)+" г.",nLen)
  @ prow()+1,00 say ""
  nLine := 3
  nNpp  := iPage := 0
  While ( nKSchet == Work->KSchet .and. !Work->(eof()) )

//  Work->SumR:= Work->KolR*((Work->SumN + Work->SumP)/(Work->KolN + Work->KolP))
    iKolK := Work->KolN + Work->KolP - Work->KolR
//    iSumK := Round(iKolK*S_Mat->Cena,ROUND_S14)
    iSumK := Work->SumN + Work->SumP - Work->SumR
//    iS14  := round(Work->KolN*S_Mat->Cena,ROUND_S14)  - Work->SumN
    iS14  := iSumk - (Work->SumN + Work->SumP - Work->SumR)
    PutObor( str(++nNpp,3)+" "+str(Work->K_mat,5)+" "+S_Mat->Naim+" "+;
             S_Mat->EdIzm+" "+str(Work->KolN,10,3)+" "+;
             str(Work->SumN,11,2)+" "+str(Work->KolP,10,3)+" "+;
             str(Work->SumP,11,2)+" "+str(Work->KolR,10,3)+" "+;
             str(Work->SumR,11,2)+" "+str(iKolK,10,3)+" "+;
             str(iSumK,11,2) ) // +" "+str(iS14,11,2) )
    nSumP += Work->SumP
    nSumR += Work->SumR
    nSumN += Work->SumN
    nS14  += iS14
    nSumK += iSumK
    nKolK += iKolK
    OSTNEWMAT->(DbAppend())
    OSTNEWMAT->K_Mat := Work->K_Mat
    OSTNEWMAT->KSchet:= nKSChet
    OSTNEWMAT->Kol   := iKolK
    OSTNEWMAT->Sum   := iSumK
    S_Line_N(18,04,65,nLastRec,++nRecno)
    Work->(Dbskip(1))
  End
  @ prow()+1,00 say repl("-",nLen)
  @ prow()+1,00 say padc("Всего",41)+;
    space(10)+str(nSumN,12,2)+" "+;
    space(10)+str(nSumP,12,2)+" "+;
    space(10)+str(nSumR,12,2)+" "+;
    space(10)+str(nSumK,12,2) // +" "+str(nS14,11,2)
  if !Work->(eof())
    nLine += 2
    For i := nLine to 66
        @ prow()+1,00 say ""
    Next
  End
  vSumP += nSumP
  vSumR += nSumR
  vSumN += nSumN
  vS14  += nS14
  vSumK += nSumK
  vKolK += nKolK
End
@ prow()+1,00 say repl("=",nLen)
@ prow()+1,00 say padc("Итого",41)+;
  space(10)+str(vSumN,12,2)+" "+;
  space(10)+str(vSumP,12,2)+" "+;
  space(10)+str(vSumR,12,2)+" "+;
  space(10)+str(vSumK,12,2) // +" "+str(vS14,11,2)
@ prow()+1,00 say " "
@ prow()+1,00 say ""
My_Char()
S_Line_N()
Set(24,"")
Set(20,"SCREEN")
ShowPrn(oFile," Ведомость ",74)
END SEQUENCE
DbCloseAll()
fErase(oFile)
Return ( Nil )
///////////////////////////////////////////////////////////////////////////
Static Function PutObor(cLine)
Local i
if iPage == 0 .or. nLine > 64
  if nLine > 64
     For i := nLine to 66
        @ prow()+1,00 say ""
     Next
     nLine := 0
  End
  @ prow()+1,00 say padr("     Лист# "+str(++nPage,3),nLen)
  @ prow()+1,00 say repl("-",nLen)
  @ prow()+1,00 say " N | код |                         | ед | остаток на нач. мес. |    п р и х о д       |  р а с х о д         | остаток на кон. мес. |"
  @ prow()+1,00 say "п/п|матер|      Наименование       |изме|----------------------|----------------------|----------------------|----------------------|"
  @ prow()+1,00 say "   |иала |                         |рен.|  к-во    |  сумма    |   к-во   |   сумма   |   к-во   |   сумма   |   к-во   |   сумма   |"
  @ prow()+1,00 say repl("-",nLen)
  nLine += 6
  iPage++
End
@ prow()+1,00 say cLine
nLine++
Return ( Nil )
// ##################################################### М О Л ###############
function MVedomPrix() // Ведомость Прихода МОЛ
Local oSum, kSum, fSum, nRecno, nLastRec, nEnt, nKSchet, nNpp
Local oFile := sset[SSET_WORK]+"MVedPrix.txt"
Private nLen := 86, nPage := 0, nLine, iPage := 0, cKsp
Private dDataRas := sset[SSET_DATA]

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
if !OpenDbf_(sset[SSET_BAZA]+"S_MAT")  ; break ; End
if !OpenDbf_(sset[SSET_BAZA]+"Rasxod") ; break ; End
Rasxod->(DbSetOrder(2))
Set filter to !Empty(Rasxod->TabN)
Set Relation to str(K_Mat,5) into S_Mat
Rasxod->(DbGoTop())
nLastRec := Rasxod->(LastRec())
S_Line_N(18,04,65,nLastRec,1)
@ 01,06 say "Ожидайте..."
@ 01,42 say "Формирую ведомость "
nRecno := "[ По окончании будет подан звуковой сигнал ]"
@ 00,(MaxCol()-len(nRecno))/2 say nRecno
nRecno := fSum := 0
Set(20,"PRINT")
Set(24,oFile)
Rasxod->(DbGoTop())
While ( !Rasxod->(eof()) )
  cKsp    := Rasxod->Ksp
  kSum    := 0
  nNpp    := 0
  aSum    := {}
  iPage   := 0
  nLine   := 0
  ssp->(dbseek(cKsp))
  While ( cKsp == Rasxod->Ksp .and. !Rasxod->(eof()) )
    nTabn := Rasxod->TabN
    Tn->(DbSeek(nTabN))
    PutMPrix( " " )
    PutMPrix( " " )
    PutMPrix( " " )
    PutMPrix( padc(nTabN+" "+alltrim(Tn->Fio),nLen) )
    nSumTn := 0
    aSchetTn := {}
    While ( nTabn == Rasxod->TabN .and. cKsp == Rasxod->Ksp .and. !Rasxod->(eof()) )
       PutMPrix( str(++nNpp,3)+" "+str(Rasxod->KSchet,5,2)+" "+;
         dtoc(Rasxod->DataP)+" "+str(Rasxod->K_Mat,5)+" "+S_Mat->Naim+" "+;
         S_Mat->EdIzm+" "+str(Rasxod->Nnak,6)+" "+str(Rasxod->Kol,9,3)+" "+;
         str(Rasxod->Sum,11,2) )
       kSum += Rasxod->Sum
       nSumTn += Rasxod->Sum
       if ( nPos := ascan(aSum,{|x| x[1] == Rasxod->KSchet }) ) == 0
          aadd(aSum,{Rasxod->KSchet,0})
          nPos := len(aSum)
       End
       aSum[nPos][2] += Rasxod->Sum
       if ( nPos := ascan(aSchetTn,{|x| x[1] == Rasxod->KSchet }) ) == 0
          aadd(aSchetTn,{Rasxod->KSchet,0})
          nPos := len(aSchetTn)
       End
       aSchetTn[nPos][2] += Rasxod->Sum
       S_Line_N(18,04,65,nLastRec,++nRecno)
       Rasxod->(DbSkip(1))
    End
    PutMPrix( padl( "Итого по МОЛ       "+str(nSumTn,11,2),nLen) )
    for i := 1 to len(aSchetTn)
        PutMPrix( padl( "В том числе по кредиту счету "+str(aSchetTn[i][1],5,2)+;
                        "            "+str(aSchetTn[i][2],11,2),nLen) )
    Next
  End
  fSum += kSum
  PutMPrix( " " )
  PutMPrix( repl("-",nLen) )
  PutMPrix( padl("Итого по подразделению       "+str(kSum,11,2),nLen) )
  for i := 1 to len(aSum)
    PutMPrix( padl("В том числе по кредиту счету "+str(aSum[i][1],5,2)+;
              "           "+str(aSum[i][2],11,2),nLen) )
  Next
  PutMPrix( " " )
  PutMPrix( " " )
  PutMPrix( " " )
  PutMPrix( " " )
End
@ prow()+1,00 say repl("-",nLen)
@ prow()+1,00 say padl("Всего по приходу     "+str(fSum,11,2),nLen)
nLine += 2
For i := nLine to 66
    @ prow()+1,00 say ""
Next
@ prow()+1,00 say ""
My_Char()
S_Line_N()
Set(24,"")
Set(20,"SCREEN")
ShowPrn(oFile," Ведомость ",74)
END SEQUENCE
DbCloseAll()
fErase(oFile)
Return ( Nil )
///////////////////////////////////////////////////////////////////////////
Static Function PutMPrix(cLine)
Local i
if iPage == 0 .or. nLine > 64
  if nLine > 64
     For i := nLine to 66
        @ prow()+1,00 say ""
     Next
     nLine := 0
  End
  if iPage == 0
     @ prow()+1,00 say padc("Ведомость прихода по подразд. "+cKsp+" "+ssp->Nbrig,nLen)
     @ prow()+1,00 say padc(" за "+S_cMonth(dDataRas)+" месяц "+str(year(dDataRas),4)+" год",nLen)
     @ prow()+1,00 say padc(" ",nLen)
     nLine := 3
  End
  @ prow()+1,00 say padr("     Лист# "+str(++nPage,3),nLen)
  @ prow()+1,00 say repl("-",nLen)
  @ prow()+1,00 say "Nпп|к счет| Дата/пол |к.мат|      наименование       |едиз| N нак|  к-во   |  сумма    "
  @ prow()+1,00 say repl("-",nLen)
  nLine += 4
  iPage++
End
@ prow()+1,00 say cLine
nLine++
Return ( Nil )
///////////////////////////////////////////////////////////////////////////
function MVedomRasx() // Ведомость Расхода МОЛ
Local oSum, kSum, fSum, nRecno, nLastRec, nEnt, nKSchet, nNpp
Local oFile := sset[SSET_WORK]+"MVedRasx.txt"
Private nLen := 81, nPage := 0, nLine, iPage := 0, cKsp
Private dDataRas := sset[SSET_DATA]


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
if !OpenDbf_(sset[SSET_BAZA]+"S_MAT")  ; break ; End
if !OpenDbf_(sset[SSET_BAZA]+"Akt")    ; break ; End
Set Relation to str(K_Mat,5) into S_Mat
Akt->(DbGoTop())
nLastRec := Akt->(LastRec())
S_Line_N(18,04,65,nLastRec,1)
@ 01,06 say "Ожидайте..."
@ 01,42 say "Формирую ведомость "
nRecno := "[ По окончании будет подан звуковой сигнал ]"
@ 00,(MaxCol()-len(nRecno))/2 say nRecno
nRecno := fSum := 0
Set(20,"PRINT")
Set(24,oFile)
Akt->(DbGoTop())
While ( !Akt->(eof()) )
  cKsp    := Akt->Ksp
  kSum    := 0
  nNpp    := 0
  aSum    := {}
  iPage := nLine := 0
  ssp->(dbseek(cKsp))
  While ( cKsp == Akt->Ksp .and. !Akt->(eof()) )
    nTabn := Akt->TabN
    Tn->(DbSeek(nTabN))
    PutMRasx( " " )
    PutMRasx( " " )
    PutMRasx( " " )
    PutMRasx( padc(nTabN+" "+alltrim(Tn->Fio),nLen) )
    tSum := {}
    nSumTn := 0
    While ( nTabn == Akt->TabN .and. cKsp == Akt->Ksp .and. !Akt->(eof()) )
       PutMRasx( str(++nNpp,3)+" "+str(Akt->Schet,5,2)+" "+;
            str(Akt->KSchet,5,2)+" "+;
            str(Akt->K_Mat,5)+" "+S_Mat->Naim+" "+;
            S_Mat->EdIzm+" "+str(Akt->Nnak,6)+" "+str(Akt->Kol,9,3)+" "+;
            str(Akt->Sum,11,2) )
          kSum += Akt->Sum
          nSumTn += Akt->Sum
          if ( nPos := ascan(aSum,{|x| x[1] == Akt->KSchet }) ) == 0
             aadd(aSum,{Akt->KSchet,0})
             nPos := len(aSum)
          End
          aSum[nPos][2] += Akt->Sum
          if ( nPos := ascan(tSum,{|x| x[1] == Akt->Schet .and. ;
                                       x[2] == Akt->KSchet }) ) == 0
             aadd(tSum,{Akt->Schet,Akt->KSchet,0})
             nPos := len(tSum)
          End
          tSum[nPos][3] += Akt->Sum
          S_Line_N(18,04,65,nLastRec,++nRecno)
          Akt->(DbSkip(1))
    End // сменился табельный
    PutMRasx( padl("Итого по МОЛ    "+str(nSumTn,11,2),nLen) )
    for i := 1 to len(tSum)
       PutMRasx( padl("В том числе по дебету счета "+str(tSum[i][1],5,2)+" "+;
                                     str(tSum[i][2],5,2)+"    "+;
                                     str(tSum[i][3],11,2),nLen) )
    Next
  End // сминилось подразделение
  fSum += kSum
//  for i := 1 to len(aSum)
//    PutMRasx( padl( "Итого по дебету счета "+str(aSum[i][1],5,2)+"     "+;
//                                   str(aSum[i][2],11,2),nLen) )
//  Next
  PutMRasx( repl("-",nLen) )
  PutMRasx( padl( "Всего по подразделению     "+str(kSum,11,2),nLen) )
  PutMRasx( " " )
  PutMRasx( " " )
  PutMRasx( " " )
End
@ prow()+1,00 say repl("-",nLen)
@ prow()+1,00 say padl ("Всего по расходу      "+str(fSum,11,2),nLen)
nLine += 2
For i := nLine to 66
   @ prow()+1,00 say ""
Next
@ prow()+1,00 say ""
My_Char()
S_Line_N()
Set(24,"")
Set(20,"SCREEN")
ShowPrn(oFile," Ведомость ",74)
END SEQUENCE
DbCloseAll()
fErase(oFile)
Return ( Nil )
///////////////////////////////////////////////////////////////////////////
Static Function PutMRasx(cLine)
Local i
if iPage == 0 .or. nLine > 64
  if nLine > 64
     For i := nLine to 66
        @ prow()+1,00 say ""
     Next
     nLine := 0
  End
  if iPage == 0
     @ prow()+1,00 say padc("Ведомость расхода по подразд. "+cKsp+" "+ssp->Nbrig,nLen)
     @ prow()+1,00 say padc(" за "+S_cMonth(dDataRas)+" месяц "+str(year(dDataRas),4)+" год",nLen)
     @ prow()+1,00 say padc(" ",nLen)
     nLine := 3
  End
  @ prow()+1,00 say padr("     Лист# "+str(++nPage,3),nLen)
  @ prow()+1,00 say repl("-",nLen)
  @ prow()+1,00 say "Nпп|счет |к счет|к.мат|      наименование       |едиз| N нак|  к-во   |  сумма    "
  @ prow()+1,00 say repl("-",nLen)
  nLine += 4
  iPage++
End
@ prow()+1,00 say cLine
nLine++
Return ( Nil )
///////////////////////////////////////////////////////////////////////////
Function MVedomObor() // Ведомость оборотная МОЛ
Local oFile := sset[SSET_WORK]+"MMatObor.Ved", nLastRec, nRecno, nKolK
Local nSumP, nSumR, nSumN, nNpp, nS14, iS14, iKolK, iSumK, nSumK
Local nCena, aSum, aSchetTn
Private nLen := 139, nPage := 0, nLine, iPage := 0
Private dDataRas := sset[SSET_DATA], cKsp

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
if !OpenDBF_(sset[SSET_BAZA]+"S_Mat")  ; break ; End
if !OpenDBF_(sset[SSET_BAZA]+"Rasxod") ; break ; End
if !OpenDBF_(sset[SSET_BAZA]+"Akt")    ; break ; End
if !OpenDBF_(sset[SSET_BAZA]+"OstMatM") ; break ; End
__DbCopyStru( (sset[SSET_BAZA]+"OstNemMat") )
use (sset[SSET_BAZA]+"OstNemMat") new alias OSTNEWMAT
fErase(sset[SSET_WORK]+"Work.dbf")
fErase(sset[SSET_WORK]+"Work.Ntx")
Dbcreate(sset[SSET_WORK]+"WORK",{ {"Ksp",   "C",04,00},;
                                  {"TabN",  "C",06,00},;
                                  {"DataP", "D",08,00},;
                                  {"KSchet","N",05,02},;
                                  {"K_mat", "N",05,00},;
                                  {"KolN",  "N",10,03},;
                                  {"SumN",  "N",11,02},;
                                  {"KolP",  "N",10,03},;
                                  {"SumP",  "N",11,02},;
                                  {"KolR",  "N",10,03},;
                                  {"SumR",  "N",11,02}})
use (sset[SSET_WORK]+"WORK") new
Index on Ksp+TabN+str(KSchet,5,2)+str(K_Mat,5) to (sset[SSET_WORK]+"WORK")
nLastRec := Rasxod->(LastRec()) + Akt->(LastRec()) + OstMatM->(LastRec())
S_Line_N(18,04,65,nLastRec,1)
@ 01,06 say "Ожидайте..."
@ 01,42 say "Формирую данные "
nRecno := "[ По окончании будет подан звуковой сигнал ]"
@ 00,(MaxCol()-len(nRecno))/2 say nRecno
nRecno := 0
Rasxod->(DbGoTop())
While !Rasxod->(eof())
  if !Empty(Rasxod->TabN)
    if !Work->(Dbseek(Rasxod->Ksp+Rasxod->TabN+str(Rasxod->KSchet,5,2)+str(Rasxod->K_Mat,5)))
        Work->(DbAppend())
        Work->K_Mat  := Rasxod->K_Mat
        Work->KSchet := Rasxod->KSchet
        Work->Ksp    := Rasxod->Ksp
        Work->TabN   := Rasxod->TabN
        Work->DataP  := Rasxod->DataP
    End
    Work->SumP += Rasxod->Sum
    Work->KolP += Rasxod->Kol
  End
  S_Line_N(18,04,65,nLastRec,++nRecno)
  Rasxod->(Dbskip(1))
End
OstMatM->(DbGoTop())
While !OstMatM->(eof())
  if !Work->(Dbseek(OstMatM->Ksp+OstMatM->TabN+str(OstMatM->KSchet,5,2)+str(OstMatM->K_Mat,5)))
      Work->(DbAppend())
      Work->K_Mat  := OstMatM->K_Mat
      Work->KSchet := OstMatM->KSchet
      Work->KSp    := OstMatM->KSp
      Work->TabN   := OstMatM->TabN
      Work->DataP  := OstMatM->DataP
  End
  Work->SumN += OstMatM->Sum
  Work->KolN += OstMatM->Kol
  S_Line_N(18,04,65,nLastRec,++nRecno)
  OstMatM->(Dbskip(1))
End
Akt->(DbGoTop())
While !Akt->(eof())
  if !Work->(Dbseek(Akt->Ksp+Akt->TabN+str(Akt->KSchet,5,2)+str(Akt->K_Mat,5)))
      Work->(DbAppend())
      Work->K_Mat  := Akt->K_Mat
      Work->KSchet := Akt->KSchet
      Work->Ksp    := Akt->Ksp
      Work->TabN   := Akt->TabN
  End
  Work->SumR += Akt->Sum
  Work->KolR += Akt->Kol
  S_Line_N(18,04,65,nLastRec,++nRecno)
  Akt->(Dbskip(1))
End
/////////////////////////////////////////////////////////////////////////
DbSelectArea("Work")
Set Relation to str(K_Mat,5) into S_MAT
S_Line_N()
nLastRec := Work->(LastRec())
S_Line_N(18,04,65,nLastRec,1)
@ 01,06 say "Ожидайте..."
@ 01,42 say "Формирую ведомость "
nRecno := "[ По окончании будет подан звуковой сигнал ]"
@ 00,(MaxCol()-len(nRecno))/2 say nRecno
nRecno := 0
vSumP := vSumR := vSumN := vSumK := 0
Set(20,"PRINT")
Set(24,oFile)
Work->(DbGoTop())
While ( !Work->(eof()) )
  cKSp := Work->KSp
  nSumP := nSumR := nSumN := nSumK := 0
  iPage := nLine := 0
  ssp->(dbseek(cKsp))
  nNpp  := 0
  aSum  := {}
  While ( cKSp == Work->KSp .and. !Work->(eof()) )
    nTabN := Work->TabN
    Tn->(DbSeek(nTabN))
    PutMObor( " " )
    PutMObor( " " )
    PutMObor( " " )
    PutMObor( padc(nTabN+" "+alltrim(Tn->Fio),nLen) )
    nSumTnP := nSumTnR := nSumTnN := nSumTnK := 0
    aSchetTn := {}
    While ( nTabn == Work->TabN .and. cKsp == Work->Ksp .and. !Work->(eof()) )
      i := int(S_Mat->SrNos)
      j := (S_Mat->SrNos - i)*100
      dDataS := S_AddMon(Work->DataP,i*12+j)
      iKolK := Work->KolN + Work->KolP - Work->KolR
//      iSumK := Round(iKolK*S_Mat->Cena,ROUND_S14)
      iSumK  := Work->SumN + Work->SumP - Work->SumR
      if !Empty(Work->KolN+Work->KolP+Work->KolR) .and. ;
         !Empty(Work->SumN+Work->SumP+Work->SumR) ////////////////////////
      PutMObor( str(++nNpp,3)+" "+str(Work->KSchet,5,2)+" "+;
        str(Work->K_mat,5)+" "+S_Mat->Naim+" "+S_Mat->EdIzm+" "+;
        str(Work->KolN,10,3)+" "+str(Work->SumN,11,2)+" "+;
        str(Work->KolP,10,3)+" "+str(Work->SumP,11,2)+" "+;
        str(Work->KolR,10,3)+" "+str(Work->SumR,11,2)+" "+;
        str(iKolK,10,3)+" "+str(iSumK,11,2) )
      nSumP += Work->SumP
      nSumR += Work->SumR
      nSumN += Work->SumN
      nSumK += iSumK
      if ( nPos := ascan(aSum,{|x| x[1] == Work->KSchet }) ) == 0
          aadd(aSum,{Work->KSchet,0,0,0,0})
          nPos := len(aSum)
      End
      aSum[nPos][2] += Work->SumP
      aSum[nPos][3] += Work->SumR
      aSum[nPos][4] += Work->SumN
      aSum[nPos][5] += iSumK
      nSumTnP += Work->SumP
      nSumTnR += Work->SumR
      nSumTnN += Work->SumN
      nSumTnK += iSumK
      if ( nPos := ascan(aSchetTn,{|x| x[1] == Work->KSchet }) ) == 0
          aadd(aSchetTn,{Work->KSchet,0,0,0,0})
          nPos := len(aSchetTn)
      End
      aSchetTn[nPos][2] += Work->SumP
      aSchetTn[nPos][3] += Work->SumR
      aSchetTn[nPos][4] += Work->SumN
      aSchetTn[nPos][5] += iSumK
      OSTNEWMAT->(DbAppend())
      OSTNEWMAT->K_Mat := Work->K_Mat
      OSTNEWMAT->KSchet:= Work->KSChet
      OSTNEWMAT->Kol   := iKolK
      OSTNEWMAT->Sum   := iSumK
      OSTNEWMAT->DataP := Work->DataP
      OSTNEWMAT->TabN  := Work->TabN
      OSTNEWMAT->Ksp   := Work->Ksp
      End //////////////////////////////////
      S_Line_N(18,04,65,nLastRec,++nRecno)
      Work->(Dbskip(1))
    End
    PutMObor( padr("Всего по МОЛ ",47)+;
      space(10)+str(nSumTnN,12,2)+" "+;
      space(10)+str(nSumTnP,12,2)+" "+;
      space(10)+str(nSumTnR,12,2)+" "+;
      space(10)+str(nSumTnK,12,2) )
    for i := 1 to len(aSchetTn)
      PutMObor( padl("В том числе по кредиту счета "+str(aSchetTn[i][1],5,2),47)+;
                        space(10)+str(aSchetTn[i][4],12,2)+" "+;
                        space(10)+str(aSchetTn[i][2],12,2)+" "+;
                        space(10)+str(aSchetTn[i][3],12,2)+" "+;
                        space(10)+str(aSchetTn[i][5],12,2) )
    Next
  End
  PutMObor( repl("-",nLen) )
  PutMObor( padr("Всего по подразделению ",47)+;
    space(10)+str(nSumN,12,2)+" "+;
    space(10)+str(nSumP,12,2)+" "+;
    space(10)+str(nSumR,12,2)+" "+;
    space(10)+str(nSumK,12,2) )
  for i := 1 to len(aSum)
    PutMObor( padl("В том числе по кредиту счета "+str(aSum[i][1],5,2),47)+;
                      space(10)+str(aSum[i][4],12,2)+" "+;
                      space(10)+str(aSum[i][2],12,2)+" "+;
                      space(10)+str(aSum[i][3],12,2)+" "+;
                      space(10)+str(aSum[i][5],12,2) )
  Next
  vSumP += nSumP
  vSumR += nSumR
  vSumN += nSumN
  vSumK += nSumK
End
@ prow()+1,00 say repl("=",nLen)
@ prow()+1,00 say padr("Итого по предприятию ",48)+;
  space(10)+str(vSumN,12,2)+" "+;
  space(10)+str(vSumP,12,2)+" "+;
  space(10)+str(vSumR,12,2)+" "+;
  space(10)+str(vSumK,12,2)
@ prow()+1,00 say " "
nLine += 3
For i := nLine to 66
    @ prow()+1,00 say ""
Next
@ prow()+1,00 say ""
My_Char()
S_Line_N()
Set(24,"")
Set(20,"SCREEN")
ShowPrn(oFile," Ведомость ",74)
END SEQUENCE
DbCloseAll()
fErase(oFile)
Return ( Nil )
/////////////////////////////////////////////////////////////////////////////
Static Function PutMObor(cLine)
Local i
if iPage == 0 .or. nLine > 64
  if nLine > 64
     For i := nLine to 66
        @ prow()+1,00 say ""
     Next
     nLine := 0
  End
  if iPage == 0
     @ prow()+1,00 say " "
     @ prow()+1,00 say padc("Оборотная ведомость по подразд. "+cKsp+" "+ssp->Nbrig,nLen)
     @ prow()+1,00 say padc("за "+S_cMonth(dDataRas)+" месяц "+str(year(dDataRas),4)+" г.",nLen)
     @ prow()+1,00 say " "
     nLine := 4
  End
  @ prow()+1,00 say padr("     Лист# "+str(++nPage,3),nLen)
  @ prow()+1,00 say repl("-",nLen)
  @ prow()+1,00 say " N |     | код |                         | ед | остаток на нач. мес. |    п р и х о д       |  р а с х о д         | остаток на кон. мес. |"
  @ prow()+1,00 say "п/п|счет |матер|      Наименование       |изме|----------------------|----------------------|----------------------|----------------------|"
  @ prow()+1,00 say "   |     |иала |                         |рен.|  к-во    |  сумма    |   к-во   |   сумма   |   к-во   |   сумма   |   к-во   |   сумма   |"
  @ prow()+1,00 say repl("-",nLen)
  nLine += 6
  iPage++
End
@ prow()+1,00 say cLine
nLine++
Return ( Nil )
///////////////////////////////////////////////////////////////////////////
Function MVedomObo_() // Ведомость оборотная МОЛ
Local oFile := sset[SSET_WORK]+"MMatObo_.Ved", nLastRec, nRecno, nKolK
Local nSumP, nSumR, nSumN, nNpp, nS14, iS14, iKolK, iSumK, nSumK
Local nCena, aSum, aSchetTn
Private nLen := 70, nPage := 0, nLine, iPage := 0
Private dDataRas := sset[SSET_DATA], cKsp

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
if !OpenDBF_(sset[SSET_BAZA]+"S_Mat")  ; break ; End
if !OpenDBF_(sset[SSET_BAZA]+"Rasxod") ; break ; End
if !OpenDBF_(sset[SSET_BAZA]+"Akt")    ; break ; End
if !OpenDBF_(sset[SSET_BAZA]+"OstMatM") ; break ; End
fErase(sset[SSET_WORK]+"Work.dbf")
fErase(sset[SSET_WORK]+"Work.Ntx")
Dbcreate(sset[SSET_WORK]+"WORK",{ {"Ksp",   "C",04,00},;
                                  {"TabN",  "C",06,00},;
                                  {"DataP", "D",08,00},;
                                  {"KSchet","N",05,02},;
                                  {"K_mat", "N",05,00},;
                                  {"KolN",  "N",10,03},;
                                  {"SumN",  "N",11,02},;
                                  {"KolP",  "N",10,03},;
                                  {"SumP",  "N",11,02},;
                                  {"KolR",  "N",10,03},;
                                  {"SumR",  "N",11,02}})
use (sset[SSET_WORK]+"WORK") new
Index on Ksp+TabN+str(KSchet,5,2)+str(K_Mat,5) to (sset[SSET_WORK]+"WORK")
nLastRec := Rasxod->(LastRec()) + Akt->(LastRec()) + OstMatM->(LastRec())
S_Line_N(18,04,65,nLastRec,1)
@ 01,06 say "Ожидайте..."
@ 01,42 say "Формирую данные "
nRecno := "[ По окончании будет подан звуковой сигнал ]"
@ 00,(MaxCol()-len(nRecno))/2 say nRecno
nRecno := 0
Rasxod->(DbGoTop())
While !Rasxod->(eof())
  if !Empty(Rasxod->TabN)
    if !Work->(Dbseek(Rasxod->Ksp+Rasxod->TabN+str(Rasxod->KSchet,5,2)+str(Rasxod->K_Mat,5)))
        Work->(DbAppend())
        Work->K_Mat  := Rasxod->K_Mat
        Work->KSchet := Rasxod->KSchet
        Work->Ksp    := Rasxod->Ksp
        Work->TabN   := Rasxod->TabN
        Work->DataP  := Rasxod->DataP
    End
    Work->SumP += Rasxod->Sum
    Work->KolP += Rasxod->Kol
  End
  S_Line_N(18,04,65,nLastRec,++nRecno)
  Rasxod->(Dbskip(1))
End
OstMatM->(DbGoTop())
While !OstMatM->(eof())
  if !Work->(Dbseek(OstMatM->Ksp+OstMatM->TabN+str(OstMatM->KSchet,5,2)+str(OstMatM->K_Mat,5)))
      Work->(DbAppend())
      Work->K_Mat  := OstMatM->K_Mat
      Work->KSchet := OstMatM->KSchet
      Work->KSp    := OstMatM->KSp
      Work->TabN   := OstMatM->TabN
      Work->DataP  := OstMatM->DataP
  End
  Work->SumN += OstMatM->Sum
  Work->KolN += OstMatM->Kol
  S_Line_N(18,04,65,nLastRec,++nRecno)
  OstMatM->(Dbskip(1))
End
Akt->(DbGoTop())
While !Akt->(eof())
  if !Work->(Dbseek(Akt->Ksp+Akt->TabN+str(Akt->KSchet,5,2)+str(Akt->K_Mat,5)))
      Work->(DbAppend())
      Work->K_Mat  := Akt->K_Mat
      Work->KSchet := Akt->KSchet
      Work->Ksp    := Akt->Ksp
      Work->TabN   := Akt->TabN
  End
  Work->SumR += Akt->Sum
  Work->KolR += Akt->Kol
  S_Line_N(18,04,65,nLastRec,++nRecno)
  Akt->(Dbskip(1))
End
/////////////////////////////////////////////////////////////////////////
DbSelectArea("Work")
Set Relation to str(K_Mat,5) into S_MAT
S_Line_N()
nLastRec := Work->(LastRec())
S_Line_N(18,04,65,nLastRec,1)
@ 01,06 say "Ожидайте..."
@ 01,42 say "Формирую ведомость "
nRecno := "[ По окончании будет подан звуковой сигнал ]"
@ 00,(MaxCol()-len(nRecno))/2 say nRecno
nRecno := 0
vSumP := vSumR := vSumN := vSumK := 0
Set(20,"PRINT")
Set(24,oFile)
Work->(DbGoTop())
While ( !Work->(eof()) )
  cKSp := Work->KSp
  iPage := nLine := 0
  ssp->(dbseek(cKsp))
  nNpp  := 0
  aSum  := {}
  While ( cKSp == Work->KSp .and. !Work->(eof()) )
    nTabN := Work->TabN
    Tn->(DbSeek(nTabN))
    PutMObo_( " " )
    PutMObo_( " " )
    PutMObo_( " " )
    PutMObo_( padc(nTabN+" "+alltrim(Tn->Fio),nLen) )
    nSumTnK := 0
    While ( nTabn == Work->TabN .and. cKsp == Work->Ksp .and. !Work->(eof()) )
      i := int(S_Mat->SrNos)
      j := (S_Mat->SrNos - i)*100
      dDataS := S_AddMon(Work->DataP,i*12+j)
      iKolK := Work->KolN + Work->KolP - Work->KolR
      iSumK  := Work->SumN + Work->SumP - Work->SumR
      if !Empty(iKolK) .and. !Empty(iSumK)
         PutMObo_( str(++nNpp,3)+" "+str(Work->KSchet,5,2)+" "+;
             str(Work->K_mat,5)+" "+S_Mat->Naim+" "+S_Mat->EdIzm+" "+;
             str(iKolK,10,3)+" "+str(iSumK,11,2) )
         nSumTnK += iSumK
      End 
      S_Line_N(18,04,65,nLastRec,++nRecno)
      Work->(Dbskip(1))
    End
    PutMObo_( padr("Всего по МОЛ ",47)+;
      space(10)+str(nSumTnK,12,2) )
  End
  PutMObo_( repl("-",nLen) )
End
@ prow()+1,00 say repl("=",nLen)
nLine += 1
For i := nLine to 66
    @ prow()+1,00 say ""
Next
@ prow()+1,00 say ""
My_Char()
S_Line_N()
Set(24,"")
Set(20,"SCREEN")
ShowPrn(oFile," Ведомость ",74)
END SEQUENCE
DbCloseAll()
fErase(oFile)
Return ( Nil )
/////////////////////////////////////////////////////////////////////////////
Static Function PutMObo_(cLine)
Local i
if iPage == 0 .or. nLine > 64
  if nLine > 64
     For i := nLine to 66
        @ prow()+1,00 say ""
     Next
     nLine := 0
  End
  if iPage == 0
     @ prow()+1,00 say " "
     @ prow()+1,00 say padc("Оборотная ведомость по подразд. "+cKsp+" "+ssp->Nbrig,nLen)
     @ prow()+1,00 say padc("за "+S_cMonth(dDataRas)+" месяц "+str(year(dDataRas),4)+" г.",nLen)
     @ prow()+1,00 say " "
     nLine := 4
  End
  @ prow()+1,00 say padr("     Лист# "+str(++nPage,3),nLen)
  @ prow()+1,00 say repl("-",nLen)
  @ prow()+1,00 say " N |     | код |                         | ед | остаток на кон. мес. |"
  @ prow()+1,00 say "п/п|счет |матер|      Наименование       |изме|----------------------|"
  @ prow()+1,00 say "   |     |иала |                         |рен.|   к-во   |   сумма   |"
  @ prow()+1,00 say repl("-",nLen)
  nLine += 6
  iPage++
End
@ prow()+1,00 say cLine
nLine++
Return ( Nil )
///////////////////////////////////////////////////////////////////////////
