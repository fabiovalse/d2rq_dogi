#!/bin/bash

if [ $# -eq 0 ]; then
  echo "Insert DB name"
  exit
fi

date=$1
#old_date=$2

### Database creation
###
echo "Insert MySQL password"
stty -echo
read pass
stty echo
echo "create database dogi_$date" | mysql --user=root --password=$pass

echo "Database creation"

### Tables import
###
prefix=`echo $date | sed -r 's/_/./g'`
path=$prefix".nir.ittig.cnr.it/dogiswish/archivi/IIT/"

unzip -d $path $path"*.zip"

cd $path
rm tabRiviste.sql

ls -1 *.sql | awk '{ print "source",$0 }' | mysql --batch --user=root --password=$pass dogi_$date

rm *.sql
rm index.html*

echo "Tables import"

### Bibliografia
###
mysql --user=root --password=$pass dogi_$date -e "ALTER TABLE tabBib ADD Translation VARCHAR(100)"
mysql --user=root --password=$pass dogi_$date -e "ALTER TABLE tabBib ADD URILabel VARCHAR(100)"
mysql --user=root --password=$pass dogi_$date -e "UPDATE tabBib SET Translation='No bibliography', URILabel='no-bibliography' WHERE IDBib = 0"
mysql --user=root --password=$pass dogi_$date -e "UPDATE tabBib SET Translation='Bibliography in the footnotes or in the body of the text', URILabel='bibliography-in-footnotes-or-body' WHERE IDBib = 1"
mysql --user=root --password=$pass dogi_$date -e "UPDATE tabBib SET Translation='Bibliography at the end of the article', URILabel='bibliography-at-end-of-article' WHERE IDBib = 2"

echo "tabBib"

### tabFonti e legDocFonte → tabSourceOfLaw
###
### mysql --user=root --password=$pass dogi_$date -e "CREATE TABLE tabSourceOfLaw AS (SELECT IDTP, tabFonti.IDFonte, IDNomeFonte, Data, Numero, Testo, Altro, Ordinanza, Decreto, IDRegione, IDCitta, IDProvincia, IDSezione, IDAutorita, IDAmministrazione, IDStato, IDMinistero, urnNirAtto, urnLexAtto, ecli, eliAtto, celexAtto, IDDoc, Articolo, RipA, Comma, RipC, Lettera, NumeroP, Allegato, testoPart, urnNirPart, urnLexPart, eliPart, celexPart FROM tabFonti JOIN legDocFonte ON tabFonti.IDFonte = legDocFonte.IDFonte GROUP BY IDFonte, urnNirPart)"
### mysql --user=root --password=$pass dogi_$date -e "ALTER TABLE tabSourceOfLaw ADD IDSourceOfLaw int NOT NULL AUTO_INCREMENT primary key FIRST"
### mysql --user=root --password=$pass dogi_$date -e "CREATE TABLE legDocSourceOfLaw AS (SELECT IDSourceOfLaw, legDocFonte.IDDoc FROM tabSourceOfLaw INNER JOIN legDocFonte ON tabSourceOfLaw.IDFonte = legDocFonte.IDFonte AND tabSourceOfLaw.urnNirPart = legDocFonte.urnNirPart)"
mysql --user=root --password=$pass dogi_$date -e "UPDATE legDocFonte set legDocFonte.LocalURI = (SELECT LocalURI FROM tabFonti WHERE tabFonti.IDFonte = legDocFonte.IDFonte) WHERE Articolo =  '' AND  RipA =  '' AND  Comma =  '' AND  RipC =  '' AND  Lettera =  '' AND  NumeroP =  '' AND  Allegato =  '' AND  testoPart =  '' AND  urnNirPart =  '' AND  urnLexPart =  '' AND  eliPart =  '' AND  celexPart =  ''"
mysql --user=root --password=$pass dogi_$date -e "CREATE TABLE tabSourceOfLaw AS (SELECT IDTP, tabFonti.IDFonte, IDNomeFonte, Data, Numero, Testo, Altro, Ordinanza, Decreto, IDRegione, IDCitta, IDProvincia, IDSezione, IDAutorita, IDAmministrazione, IDStato, IDMinistero, urnNirAtto, urnLexAtto, ecli, eliAtto, celexAtto, Articolo, RipA, Comma, RipC, Lettera, NumeroP, Allegato, testoPart, urnNirPart, urnLexPart, eliPart, celexPart, legDocFonte.LocalURI FROM tabFonti JOIN legDocFonte ON tabFonti.IDFonte = legDocFonte.IDFonte WHERE urnNirPart !=  'error' AND legDocFonte.LocalURI IS NOT NULL GROUP BY IDFonte, legDocFonte.LocalURI)"
mysql --user=root --password=$pass dogi_$date -e "ALTER TABLE tabSourceOfLaw ADD IDSourceOfLaw int NOT NULL AUTO_INCREMENT primary key FIRST"
mysql --user=root --password=$pass dogi_$date -e "CREATE TABLE legDocSourceOfLaw AS (SELECT IDSourceOfLaw, legDocFonte.IDDoc FROM tabSourceOfLaw INNER JOIN legDocFonte ON tabSourceOfLaw.IDFonte = legDocFonte.IDFonte AND tabSourceOfLaw.LocalURI = legDocFonte.LocalURI)"

echo "tabFonti e legDocFonte → tabSourceOfLaw"

### tabClassificazioni
###
mysql --user=root --password=$pass dogi_$date -e "ALTER TABLE tabClassificazioni ADD label VARCHAR(300)"
mysql --user=root --password=$pass dogi_$date -e "UPDATE tabClassificazioni, (SELECT Id, (CASE WHEN ND IS NULL THEN tabSistematici.Descrizione ELSE (CONCAT(CONCAT(tabSistematici.Descrizione, '; '), tabDescrittori.Descrizione)) END) AS label FROM tabClassificazioni JOIN tabSistematici ON tabClassificazioni.NS = tabSistematici.CodiceS LEFT JOIN tabDescrittori ON tabClassificazioni.ND = tabDescrittori.CodiceD) src SET tabClassificazioni.label = src.label where tabClassificazioni.Id = src.Id"

echo "tabClassificazioni"

### tabSistematici e tabDescrittori
### (never tested within the script)
mysql --user=root --password=$pass dogi_$date -e "ALTER TABLE dogi_${date}.tabSistematici ADD COLUMN Code VARCHAR(10) AFTER CodiceS"
mysql --user=root --password=$pass dogi_$date -e "UPDATE dogi_${date}.tabSistematici SET Code = SUBSTRING_INDEX( Sigla,  '.', 1 )"
mysql --user=root --password=$pass dogi_$date -e "UPDATE dogi_${date}.tabSistematici INNER JOIN dogi_support.tabSistematici ON dogi_${date}.tabSistematici.CodiceS = dogi_support.tabSistematici.CodiceS SET dogi_${date}.tabSistematici.Descrizione = dogi_support.tabSistematici.Descrizione WHERE dogi_${date}.tabSistematici.CodiceS = dogi_support.tabSistematici.CodiceS"
mysql --user=root --password=$pass dogi_$date -e "UPDATE dogi_${date}.tabDescrittori INNER JOIN dogi_support.tabDescrittori ON dogi_${date}.tabDescrittori.CodiceD = dogi_support.tabDescrittori.CodiceD SET dogi_${date}.tabDescrittori.Descrizione = dogi_support.tabDescrittori.Descrizione WHERE dogi_${date}.tabDescrittori.CodiceD = dogi_support.tabDescrittori.CodiceD"

echo "tabSistematici e tabDescrittori"

### tabRiviste
###
mysql --user=root --password=$pass dogi_$date -e "UPDATE tabRiviste SET ACNPurl = REPLACE(ACNPurl, '&person=false&libr={}', '')"

echo "tabRiviste"

### tabRifBibl
###
mysql --user=root --password=$pass dogi_$date -e "UPDATE tabRifBibl SET Data = REPLACE(Data, '-00', '') WHERE Data REGEXP '[0-9]*-[0-9]*-00'"

echo "tabRifBibl"

### Concept Schemes
###
mysql --user=root --password=$pass dogi_$date -e "CREATE TABLE dogi_${date}.tabConceptScheme AS (SELECT * FROM dogi_support.tabConceptScheme)"

### Linking
###
mysql --user=root --password=$pass dogi_$date -e "CREATE TABLE dogi_${date}.BPR_riviste AS (SELECT * FROM dogi_support.BPR_riviste)"
mysql --user=root --password=$pass dogi_$date -e "CREATE TABLE dogi_${date}.DBpedia_autori AS (SELECT * FROM dogi_support.DBpedia_autori)"
mysql --user=root --password=$pass dogi_$date -e "CREATE TABLE dogi_${date}.CAMERA_leggi AS (SELECT * FROM dogi_support.CAMERA_leggi)"

echo "Linking"

### Create new mapping file and restart server
###
#cd /home/fvalse/d2rq-0.8.1
#cp mapping_$oldDate.ttl mapping_$date.ttl

### Update data for visualizations
###
#cd /home/fvalse/d2rq-0.8.1
#./d2r-query -f json mapping_$date.ttl "SELECT ?c (COUNT(?i) AS ?cont) { ?i a ?c } GROUP BY ?c" > webapp/snorql/data/classes.json
#cp webapp/snorql/data/classes.json webapp/snorql/data/class_count/$date.json

### Dump Creation
###
#cd /home/fvalse/d2rq-0.8.1/
#./dump-rdf -b 'http://www.dogi.cnr.it/resource/' -o dump_$date.nt.nt mapping.ttl
#mv dump_$date.nt webapp/snorql/dump/
#change the root template file for adding the new dump
