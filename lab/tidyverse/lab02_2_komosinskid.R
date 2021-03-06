####################
library(tidyr)
library(PogromcyDanych)
library(dplyr)

auta <- auta2012

### 1
#Kt�ra Marka wyst�puje najcz�ciej w zbiorze danych auta2012?
auta %>%
  group_by(Marka) %>%
  summarise(n=n()) %>%
  arrange(-n) %>%
  head(1)
#1 Volkswagen 22826

### 2
#Spo�r�d aut marki Toyota, kt�ry model wyst�puje najcz�ciej.
auta %>%
  filter(Marka=="Toyota") %>%
  group_by(Model) %>%
  summarise(n=n()) %>%
  arrange(-n)
#  1 Yaris          1552

### 3
#Sprawd� ile jest aut z silnikiem diesla wyprodukowanych w 2007 roku?
unique(auta$Rodzaj.paliwa)

auta %>%
  filter(Rodzaj.paliwa=="olej napedowy (diesel)", Rok.produkcji==2007) %>%
  summarise(n=n())

### 4
#Jakiego koloru auta maj� najmniejszy medianowy przebieg?
auta %>%
  group_by(Kolor) %>%
  summarise(med=median(Przebieg.w.km, na.rm=TRUE)) %>%
  arrange(med)
#1 bialy-metallic         60000

### 5
#Gdy ograniczy� si� tylko do aut wyprodukowanych w 2007, kt�ra Marka wyst�puje najcz�ciej w zbiorze danych auta2012?
auta %>%
  filter(Rok.produkcji==2007) %>%
  group_by(Marka) %>%
  summarise(n=n()) %>%
  arrange(-n)
# 1 Volkswagen  1679

### 6
#Spo�r�d aut marki Toyota, kt�ry model najbardziej straci� na cenie pomi�dzy rokiem produkcji 2007 a 2008.
auta %>%
  filter(Marka=="Toyota", Rok.produkcji<=2008, Rok.produkcji>=2007) %>%
  select(Marka, Model, Rok.produkcji, Cena.w.PLN) %>%
  group_by(Model, Rok.produkcji) %>%
  summarise(srCena=mean(Cena.w.PLN)) %>%
  spread(Rok.produkcji, srCena) %>%
  mutate(strata=`2008`-`2007`) %>%
  arrange(strata)
#  1 Hiace          49900  19900 -30000 

### 7
#Spo�r�d aut z silnikiem diesla wyprodukowanych w 2007 roku kt�ra marka jest najdro�sza?
auta %>%
  filter(Rok.produkcji==2007, Rodzaj.paliwa=="olej napedowy (diesel)") %>%
  group_by(Marka) %>%
  summarise(srCena=mean(Cena.w.PLN)) %>%
  arrange(-srCena)
# 1 Porsche       117045

### 8
#Ile jest aut z klimatyzacj�?
auta %>%
  filter( grepl("klimatyzacja", Wyposazenie.dodatkowe)) %>%
  summarise(n=n())
# 1 162960

### 9
#Gdy ograniczy� si� tylko do aut z silnikiem ponad 100 KM, kt�ra Marka wyst�puje najcz�ciej w zbiorze danych auta2012?
auta %>%
  filter(KM>100) %>%
  group_by(Marka) %>%
  summarise(n=n()) %>%
  arrange(-n)
# 1 Volkswagen    13317

### 10
#Spo�r�d aut marki Toyota, kt�ry model ma najwi�ksz� r�nic� cen gdy por�wna� silniki benzynowe a diesel?
auta %>%
  filter(Marka=="Toyota", Rodzaj.paliwa %in% c("olej napedowy (diesel)", "benzyna")) %>%
  group_by(Model, Rodzaj.paliwa) %>%
  summarise(srCena=mean(Cena.w.PLN)) %>%
  spread(Rodzaj.paliwa, srCena) %>%
  mutate(roznica = abs(benzyna - `olej napedowy (diesel)`))%>%
  arrange(-roznica)
# 1 Camry           51543                     3200   48343 
  
### 11
#Spo�r�d aut z silnikiem diesla wyprodukowanych w 2007 roku kt�ra marka jest najta�sza?
auta %>%
  filter(Rok.produkcji==2007, Rodzaj.paliwa=="olej napedowy (diesel)") %>%
  group_by(Marka) %>%
  summarise(srCena=mean(Cena.w.PLN)) %>%
  arrange(srCena)
# 1 Aixam     13533

### 12
#W jakiej marce klimatyzacja jest najcz�ciej obecna?
auta %>%
  filter( grepl("klimatyzacja", Wyposazenie.dodatkowe)) %>%
  group_by(Marka) %>%
  summarise(n=n()) %>%
  arrange(-n)
# 1 Volkswagen    17145

### 13
#Gdy ograniczy� si� tylko do aut o cenie ponad 50 000 PLN, kt�ra Marka wyst�puje najcz�ciej w zbiorze danych auta2012?
auta %>%
  filter(Cena.w.PLN > 50000) %>%
  group_by(Marka) %>%
  summarise(n=n()) %>%
  arrange(-n)
#  1 Audi           4374

### 14
#Spo�r�d aut marki Toyota, kt�ry model ma najwi�kszy medianowy przebieg?
auta %>%
  filter(Marka=="Toyota") %>%
  group_by(Model) %>%
  summarise(med=median(Przebieg.w.km, na.rm=TRUE)) %>%
  arrange(-med)
#  1 Carina        203000

### 15
#Spo�r�d aut z silnikiem diesla wyprodukowanych w 2007 roku kt�ry model jest najdro�szy?
auta %>%
  filter(Rok.produkcji==2007, Rodzaj.paliwa=="olej napedowy (diesel)") %>%
  group_by(Model) %>%
  summarise(srCena=mean(Cena.w.PLN)) %>%
  arrange(-srCena)
# 1 G 320  271633

### 16
#W jakim modelu klimatyzacja jest najcz�ciej obecna?
auta %>%
  filter( grepl("klimatyzacja", Wyposazenie.dodatkowe)) %>%
  group_by(Model) %>%
  summarise(n=n()) %>%
  arrange(-n)
# 1 Passat   6124

### 17
#Gdy ograniczy� si� tylko do aut o przebiegu poni�ej 50 000 km o silniku diesla, kt�ra Marka wyst�puje najcz�ciej w zbiorze danych auta2012?
auta %>%
  filter(Przebieg.w.km<50000, Rodzaj.paliwa=="olej napedowy (diesel)") %>%
  group_by(Marka) %>%
  summarise(n=n()) %>%
  arrange(-n)
#  1 BMW            1217

### 18
#Spo�r�d aut marki Toyota wyprodukowanych w 2007 roku, kt�ry model jest �rednio najdro�szy?
auta %>%
  filter(Marka=="Toyota", Rok.produkcji==2007) %>%
  group_by(Model) %>%
  summarise(srCena=mean(Cena.w.PLN, na.rm=TRUE)) %>%
  arrange(-srCena)
# 1 Land Cruiser  101566  

### 19
#Spo�r�d aut z silnikiem diesla wyprodukowanych w 2007 roku kt�ry model jest najta�szy?
auta %>%
  filter(Rok.produkcji==2007, Rodzaj.paliwa=="olej napedowy (diesel)") %>%
  group_by(Model) %>%
  summarise(srCena=mean(Cena.w.PLN, na.rm=TRUE)) %>%
  arrange(srCena)
# 1 Thesis      2000

#Jakiego koloru auta maj� najwi�kszy medianowy przebieg?
auta %>%
  group_by(Kolor) %>%
  summarise(med=median(Przebieg.w.km, na.rm=TRUE)) %>%
  arrange(-med)
# 1 bordowy            175500
