#INCLUDE "TOTVS.CH"  

User Function MT110CP2()//ExecBlock("MT110CP2",.F.,.F.,{aItens,oQual})
Local aItens := PARAMIXB[1]                           
Local oQual  := PARAMIXB[2] //adA110Data
Local _aHead := oQual:AHEADERS
For x:= 1 To Len(aItens) 
	AaDd(aItens[x],'teste')
Next	
//@ 1.6,.7 LISTBOX oQual VAR cVar Fields HEADER OemToAnsi(STR0042),OemToAnsi(STR0043),OemToAnsi(STR0044),OemToAnsi(STR0045),OemToAnsi(STR0046),OemToAnsi(STR0047),OemToAnsi(STR0048) SIZE aPosObj[1][4],aPosObj[1][3]-18 //	"Produto"##"Unid.Medida"##"Quantidade"##"Observacao"##"Dt.Emissao"##"Descricao"##"Fil.Entrega"
//oQual:SetArray(aItens)
//oQual:bLine := { || {aItens[oQual:nAT][1],aItens[oQual:nAT][2],aItens[oQual:nAT][3],aItens[oQual:nAT][4],aItens[oQual:nAT][5],aItens[oQual:nAT][6],aItens[oQual:nAT][7]}}
oQual:AddColumn(TCColumn():New("Produto"		,{|| aItens[oQual:nAt,01] },"",,,"LEFT" ,030,.F.,.F.,,,,,))
oQual:AddColumn(TCColumn():New("Descricao"		,{|| aItens[oQual:nAt,06] },"",,,"LEFT" ,120,.F.,.F.,,,,,))
oQual:AddColumn(TCColumn():New("Unid.Medida"	,{|| aItens[oQual:nAt,02] },"",,,"LEFT" ,040,.F.,.F.,,,,,))
oQual:AddColumn(TCColumn():New("Quantidade"		,{|| aItens[oQual:nAt,03] },"",,,"LEFT" ,040,.F.,.F.,,,,,))
oQual:AddColumn(TCColumn():New("Observacao"		,{|| aItens[oQual:nAt,04] },"",,,"LEFT" ,120,.F.,.F.,,,,,))
oQual:AddColumn(TCColumn():New("Dt.Emissao"		,{|| aItens[oQual:nAt,05] },"",,,"LEFT" ,030,.F.,.F.,,,,,))
oQual:AddColumn(TCColumn():New("Fil.Entrega"	,{|| aItens[oQual:nAt,07] },"",,,"LEFT" ,020,.F.,.F.,,,,,))
//oQual:AddColumn(TCColumn():New("Observação"		,{|| aItens[oQual:nAt,08] },"",,,"LEFT" ,020,.F.,.F.,,,,,))
oQual:SetArray(aItens)

Return(aItens,oQual)