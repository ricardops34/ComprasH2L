#INCLUDE "TOTVS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �M110STTS  �Autor  �Ricardo P Sotomayor � Data �  11/07/16   ���
�������������������������������������������������������������������������͹��
���Desc.     � Usado para desfazer aprova��o em SC alteradas.             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/


/*
//������������������������������������������������������������������������������������������������������������������������������������Đ�
//�Function A110Inclui, A110Altera,  e A110Deleta responsaveis pela inclus�o, altera��o, exclus�o e c�pia das Solicita��es de Compras. �
//������������������������������������������������������������������������������������������������������������������������������������Đ�
*/
User Function M110STTS()
Local _cNumSC	:= Paramixb[1]//Numero da Solicita��o
Local _nOpt		:= Paramixb[2]//1-Incluir   2 - Alterar   ///3=inclus�o / 4=altera��o / 5=exclus�o
Local _aArea	:= GetArea()
Local _aAreaSC1	:= SC1->(GetArea())
Local _cPreProd	:= GetMV("MV_M110PRE")
Local aPreProd  := {}      
Local cPreProd  := ""
Local _nItem 	:= 0
Private cJustifica	:= CriaVar("C1_JUSTIF")
Private oJustifica
Private _nOpc := 0
Private cEOL  := "CHR(13)+CHR(10)"
Private _cStatus1  
Private _lPre := .F.

If GetMV("MV_USAM110")== "S"
	DbSelectArea("SC1")
	DbSetOrder(1)
	DbGoTop()
	If DbSeek(xFilial("SC1")+_cNumSC)
		While SC1->(!Eof()) .And. SC1->(C1_FILIAL+C1_NUM)==xFilial("SC1")+_cNumSC
			If Alltrim(SC1->C1_PRODUTO) == Alltrim(_cPreProd)
        		_lPre := .T.
   				cPreProd+= Alltrim(SC1->C1_OBS)+" ;"
			EndIf
			SC1->(DbSkip())
		End
	EndIf 
	
	DbSelectArea("SC1")
	DbSetOrder(1)
	DbGoTop()
	If DbSeek(xFilial("SC1")+_cNumSC)
		While SC1->(!Eof()) .And. SC1->(C1_FILIAL+C1_NUM)==xFilial("SC1")+_cNumSC
			_nItem += 1
			If RecLock("SC1")
				SC1->C1_APROV   := "B"
				SC1->C1_DATAAPR := CtoD("")
				SC1->C1_HORAAPR := ""
				If _nOpt == 1//3
					SC1->C1_HISTMOV := U_MNTHIST(SC1->C1_HISTMOV,"Inclus�o de SC","I")
	        		If _lPre                                                             
						SC1->C1_HISTMOV := U_MNTHIST(SC1->C1_HISTMOV,"SC Com Pr� Produto: "+cPreProd,"P")
					EndIF	
					If _nItem ==1	                                                           
						U_SC1NOTF("1","Inclus�o de Solicita��o de Compras",,'mata110.html')
					EndIf	
				ElseIf _nOpt == 2 //4
					_cMensg := "Altera��o de SC"
					If SC1->C1_USER == RetCodUsr()
						_cMensg += " SC alterada pelo solicitante."
					EndIF
					SC1->C1_HISTMOV := U_MNTHIST(SC1->C1_HISTMOV,_cMensg,"U")
	        		If _lPre
						SC1->C1_HISTMOV := U_MNTHIST(SC1->C1_HISTMOV,"SC Com Pr� Produto: "+cPreProd,"P")
					EndIF	
					If _nItem ==1 
						_cMensg := "Altera��o de Solicita��o de Compras(Bloqueio)."
						If SC1->C1_USER == RetCodUsr() 
						  	_cMensg += " SC alterada pelo solicitante."
						EndIf		                                                           
						U_SC1NOTF("2",_cMensg ,,'mata110.html')
					EndIf	
				Else
					SC1->C1_HISTMOV := U_MNTHIST(SC1->C1_HISTMOV,"Bloqueio de SC","B")
					If _nItem ==1	                                                           
						U_SC1NOTF("2","Altera��o de Solicita��o de Compras(Bloqueio)",,'mata110.html')
					EndIf	
				EndIf
				SC1->(MsUnlock())
			EndIf
			SC1->(DbSkip())
		End
	EndIf
EndIf
Return