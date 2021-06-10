#!/bin/bash
#AUTHOR: EDSON BRENNO
#DATE: 18/09/2021
#Contact: etbsecurity@gmail.com


#funcoes:
ajuda(){ #possui as informacoes de como utilizar a ferramenta
	
	img=`ls sources/images/ | sort -R | head -n1`
	echo -e "\e[35m===========================================================================\e[39m"
	echo -e "\e[34m$(figlet " 		                      ETB")\e[39m"	
	echo -e "\e[95m $(cat sources/images/$img) \e[39m"
	echo -e "\e[96m$(figlet "           Metadados")"
	echo -e "---------------------ETB METADOS information-----------------------------\e[39m"
	echo -e ""
	echo -e "          Try: $0 [site] [archive of type]"
	echo -e "             Ex: $0 etbsecurity.com pdf"
	echo -e ""
	echo -e "\e[96m---------------------Types of Archives Supported---------------------\e[39m"
	echo -e "                ------------------------------------"
	echo -e "                |  pdf  |   doc  |  docx  |  xls   |"
	echo -e "                ------------------------------------"
	echo -e "                        |  xlsx  |  ppt  |"
	echo -e "                        ------------------"
	echo -e "                            |  pptx  |"
	echo -e "                            ----------"	

}

obterlinks(){ #obtendo os ips com base no tipo de arquivos passados

	links=`lynx -listonly --dump "https://google.com/search?&q=site:$1+ext:$2" | grep ".$2" | cut -d "=" -f2 | egrep -v "site|google" | sed 's/...$//'`

	for i in $links
	do
		echo "$i"

	done
}

download(){ #Will Download the archives	

	wget -P sources/archives/ $1 2>/dev/null

}

intro(){ #Introduction for creatingreport
	img=`ls sources/images/ | sort -R | head -n1`

	echo -e "======================================================================================================================================================" >> $1
			
			figlet " 		                      ETB"	>> $1
			
			cat sources/images/"$img" >> $1

			figlet "           Metadados" >> $1

	echo -e "======================================================================================================================================================" >> $1
	echo " " >> $1
	echo " " >> $1
}

creatingreport(){ #will create the report

	tot=`ls sources/archives/ | wc -l` #will receive how many archives was downloaded

	if [ "`ls reports | grep -o "$1"`" == "$1" ]
	then

		arch=`echo "reports/$1/$1.$2.txt"`

		intro $arch

			for c in  1 "$tot" 
			do
				archname=`ls sources/archives/ | sed -n "$c"p`
				echo -e "======================================================================================================================================================" >> "$arch"
				echo -e "						$archname" >> "$arch" 2>/dev/null
				echo -e "======================================================================================================================================================" >> "$arch" 
					exiftool sources/archives/"$archname" >> "$arch"
				echo -e "======================================================================================================================================================" >> "$arch" 
				echo "" >> "$arch"

			done
	
	else
		mkdir "reports/$1"

		arch=`echo "reports/$1/$1.$2.txt"`

		intro $arch

			for c in  1 "$tot" 
			do

				archname=`ls sources/archives/ | sed -n "$c"p`	
				echo -e "======================================================================================================================================================" >> "$arch"
				echo -e "						$archname" >> "$arch" 2>/dev/null
				echo -e "======================================================================================================================================================" >> "$arch" 
					exiftool sources/archives/"$archname" >> "$arch"
				echo -e "======================================================================================================================================================" >> "$arch" 
				echo "" >> "$arch"

			done
	fi

	rm -r sources/archives
	
	mkdir sources/archives
}

execucao(){ #executa o objetivo principal
	
	img=`ls sources/images/ | sort -R | head -n1`

	echo -e "\e[35m===========================================================================\e[39m"
	echo -e "\e[34m$(figlet " 		                      ETB")\e[39m"	
	echo -e "\e[95m $(cat sources/images/$img) \e[39m"
	echo -e "\e[96m$(figlet "           Metadados")"
	echo -e "\e[35m=======================================================================================\e[39m"
	echo -e "	    \e[93m[+]\e[37m Obtaining links with $2 in \e[92m$1\e[39m..."
	 	
		 links=$(obterlinks $1 $2) #vai receber os links encontrados

		if [ "$links" == "" ]
		then

			echo -e "\e[35m===========================================================================\e[39m"
			echo -e "\e[91m          Didn't found any links with $2 in $1! :("
			echo -e "\e[35m===========================================================================\e[39m"
			echo -e "\e[92m    Try to use first the scan mode. ex: $0 $1 -mS"
			echo -e "\e[35m===========================================================================\e[39m"
			exit
		
		else

			echo -e "\e[35m=======================================================================================\e[39m"
			echo -e "                      \e[93m[+]\e[32m Downloading the archives\e[37m..."
				for c in $links
				do
					download $c
				done

			echo -e "\e[35m=======================================================================================\e[39m"
		fi
	
	echo -e "                         \e[93m [+] \e[92m Creating Report....\e[32m"
		
		creatingreport $1 $2

	echo -e "\e[35m=======================================================================================\e[39m"
	echo -e "   Saved in\e[31m reports/$1/$1.$2.txt \e[39m"
	echo -e "\e[35m=======================================================================================\e[39m"
	echo -e "         			   \e[31m DONE! :) \e[39m"
	echo -e "\e[35m=======================================================================================\e[39m"
}




#Inicio:
t="0" #vai se usada para validar o tipo de documento

q=`cat sources/typesarchives` #recebe os tipos de arquivos suportados

for i in $q
do
	if [ "$2" == "$i" ] #se o tipo de arquivo passado pelo usuario for igual a um dos tipos suportados
	then
	#arquivos suportados: pdf,doc,docx,xls,xlsx,ppt,pptx
		t="1" #neste caso aquivo valido
	fi
done

#validacao de argumentos:
if [ "$1" == "" ] #caso o usuario nao passe nehum argumento
then
	ajuda 

elif [ "$1" == "-h" ] #caso o usuario use -h
then
	ajuda

elif [ "$1" == "--help" ] #caso o usuario use --help
then
	ajuda

elif [ "`echo "$1" | grep -o "\." | head -n1`" != "." ] #caso o usuario nao passe um site como argumento
then
	ajuda

elif [ "`echo "$1" | grep -o "\." | head -n1`" == "." ] && [ "$2" == "" ] #caso o usuario nao passe o tipo de arquivo 
then
	ajuda

elif [ "`echo "$1" | grep -o "\." | head -n1`" == "." ] && [ "$t" == "0" ] #caso o tipo de arquivo nao seja suportado
then
	ajuda

elif [ "`echo "$1" | grep -o "\." | head -n1`" == "." ] && [ "$t" == "1" ] && [ "$3" == "-v" ]
then
	echo "chegou"

elif [ "`echo "$1" | grep -o "\." | head -n1`" == "." ] && [ "$t" == "1" ] #caso esteja tudo certo
then
	execucao $1 $2

else #caso ainda haja problemas ao passar dos argumentos
	ajuda
fi

