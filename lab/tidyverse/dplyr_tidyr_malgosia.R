#---- �adowanie pakiet�w

library(dplyr)
library(tidyr)
library(PogromcyDanych)  #st�d s� auta2012

#---- dane

auta <- auta2012[,c("Cena.w.PLN", "KM", "Marka", "Model", "Przebieg.w.km", "Rodzaj.paliwa",
                    "Rok.produkcji")]
head(auta2012)
dim(auta)
colnames(auta)


# --- DPLYR ---

# najdro�sze auto

max(auta$Cena.w.PLN)
auta[which.max(auta$Cena.w.PLN),]

# wybieranie wierszy 

tanie_auta <- filter(auta, Cena.w.PLN < 50000)
tanie_Chevrolety <- filter(auta, Cena.w.PLN < 50000, Marka == "Chevrolet")

# o attach - dodaje nazwy kolumn do przestrzeni nazw

tanie_Fiaty <- filter(auta, Cena.w.PLN < 1000, Marka == "Fiat")
dim(tanie_Fiaty)

# przecinki zostawiaj� dowolno�� interpreterowi - tak lepiej i wygodniej
# mo�emy przez przypadek nadpisa� "filter" innym pakietem - popularna nazwa
# lepiej pisa� dplyr::filter

# wybieranie kolumn

tanie_auta_mniejsze <- select(tanie_auta, Marka:Przebieg.w.km, Rok.produkcji)
# -- uwaga: select akceptuje regexy

# sortowanie

auta <- auta[order(auta$Cena.w.PLN),]  # tak w bazowym R

tmp <- arrange(tanie_Fiaty, Rodzaj.paliwa, desc(Cena.w.PLN))
head(tmp)

# najta�sze benzynowe Fiaty
tmp2 <- filter(tmp, Rodzaj.paliwa=="benzyna")
tmp2 <- filter(tmp2, Cena.w.PLN == min(tmp2$Cena.w.PLN))

# o operatorach:
`%kot%` <- function(x,y) paste0(x, "Siena", y)
"o" %kot% "d"

# `%>%` <- function(x, f, ...) f(x, ...)
# operator "dziubek" czyt. ang. then albo pipe

# operator -> te� istnieje - przypisanie w praw� stron� - �eby korzystanie z pipe by�o naturalniejsze

auta %>%
  filter(Cena.w.PLN < 50000) %>%
  select(-Rok.produkcji) %>%
  arrange(Rodzaj.paliwa, desc(Cena.w.PLN)) %>%
  head(2) -> nowe_auta

# wprost mo�na pokaza�, gdzie wstawi� argument (kiedy ten argument nie jest pierwszy)
auta %>%
  lm(Cena.w.PLN~Rok.produkcji, data=.)

"ala" %>%
  paste(.,.)

# Zadanie ??? najta�sze Fiaty na benzyn�

auta %>%
  filter(Cena.w.PLN < 50000, Marka == "Fiat") %>%
  arrange(Rodzaj.paliwa, Cena.w.PLN) %>%
  head(10) -> Fiaty_dla_brata

# summarise, group_by: agregowanie

auta %>% 
  summarise(mean_cena = mean(Cena.w.PLN),
            n = n(),
            median_Przebieg = median(Przebieg.w.km, na.rm = TRUE))


auta %>%
  group_by(Marka, Rodzaj.paliwa) %>%    # dodaje atrybut vars - warstwowanie
  summarise(mean_cena = mean(Cena.w.PLN),
            n = n(),
            median_Przebieg = median(Przebieg.w.km, na.rm = TRUE)) %>%
  filter(n > 9000) %>%
  arrange(-mean_cena)

# data.frame - wolny
# data.table - pierwsze ulepszenie
# df.dt - tbl - tibble
# w dplyr konwertujemy na tibble, �eby by�o szybciej

# dodanie nowej kolumny: mutate

auta %>%
  group_by(Marka) %>%
  mutate(min = mean(Cena.w.PLN),                          # mean po grupach Marka
         unormowana = Cena.w.PLN / mean(Cena.w.PLN)) %>%  # mean po grupach Marka
  arrange(desc(Marka)) %>%
  ungroup() %>%                                           # pozbywamy si� grup
  mutate(min_ogolne = min(Cena.w.PLN))                    # mean po ca�o�ci

auta %>%
  mutate(Cena.na.km = Cena.w.PLN / Przebieg.w.km,
         Cena.na.mile = Cena.na.km/1.6) %>%               # dziala!
  head(20)



# --- TIDYR ---

auta %>%
  filter(Rok.produkcji > 2005) %>%
  group_by(Marka, Rok.produkcji) %>%
  summarise(srCena = mean(Cena.w.PLN)) -> agregat
  

# z D�UGIEJ do SZEROKIEJ:
#      t.dluga  klucz          wartosc
spread(agregat, Rok.produkcji, srCena) -> szeroka

spread(agregat, Marka, srCena) -> szeroka_marka

# Hadley youtube dlaczego niewarto u�ywa� klikanych narz�dzi
# po pytaniu Dariusz o Exscela xD

# z SZEROKIEJ do D�UGIEJ:
szeroka %>%
  gather(Rok, srednia_cena, -Marka)


# -- Tabela z eurostatu
library(eurostat)
db <- get_eurostat("educ_uoe_enrt01", type="label", stringsAsFactors = FALSE)
head(db)

db %>%
  filter(sex == "Females") %>%
  spread(geo, values) -> szeroka_db

szeroka_db %>%
  gather(kraj, wartosc, -(unit:time)) -> db_2


#---------- Zadania --------------

auta <- auta2012

# 1. Kt�ra Marka wyst�puje najcz�ciej w zbiorze danych auta2012?

auta %>%
  group_by(Marka) %>%
  summarise(liczba = n()) %>%
  arrange(desc(liczba)) %>%
  head(1)

# 2. Spo�r�d aut marki Toyota, kt�ry model wyst�puje najcz�ciej.

auta %>%
  filter(Marka == "Toyota") %>%
  group_by(Model) %>%
  summarise(liczba = n()) %>%
  arrange(desc(liczba)) %>%
  head(1)

# 3. Sprawd� ile jest aut z silnikiem diesla wyprodukowanych w 2007 roku?

auta %>%
  filter(Rodzaj.paliwa == "olej napedowy (diesel)", Rok.produkcji == 2007) %>%
  summarise(liczba = n())

# 4. Jakiego koloru auta maj� najmniejszy medianowy przebieg?

auta %>%
  group_by(Kolor) %>%
  summarise(median_km = median(Przebieg.w.km, na.rm = TRUE)) %>%
  filter(median_km == min(median_km))

# 5. Gdy ograniczy� si� tylko do aut wyprodukowanych w 2007, kt�ra Marka wyst�puje najcz�ciej w zbiorze danych auta2012?

auta %>%
  filter(Rok.produkcji == 2007) %>%
  group_by(Marka) %>%
  summarise(liczba = n()) %>%
  arrange(desc(liczba)) %>%
  head(1)

# 6. Spo�r�d aut marki Toyota, kt�ry model najbardziej straci� na cenie pomi�dzy rokiem produkcji 2007 a 2008.

auta %>%
  filter(Marka == "Toyota", Rok.produkcji %in% c(2007, 2008)) %>%
  group_by(Model, Rok.produkcji) %>%
  summarise(sr_cena = mean(Cena.w.PLN)) %>%
  spread(Rok.produkcji, sr_cena) %>%
  mutate(roznica = `2008` - `2007`) %>%
  ungroup() %>%
  filter(roznica == min(roznica, na.rm = TRUE))

# 7. Spo�r�d aut z silnikiem diesla wyprodukowanych w 2007 roku kt�ra marka jest najdro�sza?

auta %>%
  filter(Rodzaj.paliwa == "olej napedowy (diesel)", Rok.produkcji == 2007) %>%
  group_by(Marka) %>%
  summarise(sr_cena = mean(Cena.w.PLN, na.rm = TRUE)) %>%
  filter(sr_cena == max(sr_cena))

# 8. Ile jest aut z klimatyzacj�?

auta %>% 
  filter(grepl("klimatyzacja", Wyposazenie.dodatkowe)) %>%
  summarise(suma = n())

# 9. Gdy ograniczy� si� tylko do aut z silnikiem ponad 100 KM, kt�ra Marka wyst�puje najcz�ciej w zbiorze danych auta2012?

auta %>% 
  filter(KM > 100) %>%
  group_by(Marka) %>%
  summarise(liczba = n()) %>%
  arrange(desc(liczba)) %>%
  head(1)

# 10. Spo�r�d aut marki Toyota, kt�ry model ma najwi�ksz� r�nic� cen gdy por�wna� silniki benzynowe a diesel?

auta %>%
  filter(Marka == "Toyota", Rodzaj.paliwa %in% c("olej napedowy (diesel)", "benzyna")) %>%
  group_by(Model, Rodzaj.paliwa) %>%
  summarise(sr_cena = mean(Cena.w.PLN, na.rm= TRUE)) %>%
  spread(Rodzaj.paliwa, sr_cena) %>%
  mutate(roznica = abs(`olej napedowy (diesel)` - `benzyna`)) %>%
  ungroup() %>%
  filter(roznica == max(roznica, na.rm = TRUE))

# 11. Spo�r�d aut z silnikiem diesla wyprodukowanych w 2007 roku kt�ra marka jest najta�sza?

auta %>%
  filter(Rodzaj.paliwa == "olej napedowy (diesel)", Rok.produkcji == 2007) %>%
  group_by(Marka) %>%
  summarise(srednia_cena = mean(Cena)) %>%
  filter(srednia_cena == min(srednia_cena))

# 12. W jakiej marce klimatyzacja jest najcz�ciej obecna?

auta %>% 
  filter(grepl("klimatyzacja", Wyposazenie.dodatkowe)) %>%
  group_by(Marka) %>%
  summarise(suma = n()) %>%
  filter(suma == max(suma))

# 13. Gdy ograniczy� si� tylko do aut o cenie ponad 50 000 PLN, kt�ra Marka wyst�puje najcz�ciej w zbiorze danych auta2012?

auta %>% 
  filter(Cena > 50000) %>%
  group_by(Marka) %>%
  summarise(suma = n()) %>%
  filter(suma == max(suma))

# 14. Spo�r�d aut marki Toyota, kt�ry model ma najwi�kszy medianowy przebieg?

auta %>% 
  filter(Marka == "Toyota") %>%
  group_by(Model) %>%
  summarise(suma = median(Przebieg.w.km, na.rm = TRUE)) %>%
  filter(suma == max(suma, na.rm = TRUE))

# 15. Spo�r�d aut z silnikiem diesla wyprodukowanych w 2007 roku kt�ry model jest najdro�szy?

auta %>%
  filter(Rodzaj.paliwa == "olej napedowy (diesel)", Rok.produkcji == 2007) %>%
  group_by(Marka, Model) %>%
  summarise(srednia_cena = mean(Cena.w.PLN)) %>%
  ungroup() %>%
  filter(srednia_cena == max(srednia_cena))

auta %>%
  filter(Rodzaj.paliwa == "olej napedowy (diesel)", Rok.produkcji == 2007) %>%
  group_by(Model) %>%
  summarise(srednia_cena = mean(Cena.w.PLN)) %>%
  ungroup() %>%
  filter(srednia_cena == max(srednia_cena))

# 16. W jakim modelu klimatyzacja jest najcz�ciej obecna?

auta %>% 
  filter(grepl("klimatyzacja", Wyposazenie.dodatkowe)) %>%
  group_by(Marka, Model) %>%
  summarise(suma = n()) %>%
  ungroup() %>%
  filter(suma == max(suma))

# 17. Gdy ograniczy� si� tylko do aut o przebiegu poni�ej 50 000 km o silniku diesla, 
#     kt�ra Marka wyst�puje najcz�ciej w zbiorze danych auta2012?

auta %>%
  filter(Rodzaj.paliwa == "olej napedowy (diesel)", Przebieg.w.km < 50000) %>%
  group_by(Marka) %>%
  summarise(suma = n()) %>%
  ungroup() %>%
  filter(suma == max(suma))

# 18. Spo�r�d aut marki Toyota wyprodukowanych w 2007 roku, kt�ry model jest �rednio najdro�szy?

auta %>%
  filter(Marka == "Toyota", Rok.produkcji == 2007) %>%
  group_by(Model) %>%
  summarise(sr_cena = mean(Cena.w.PLN)) %>%
  ungroup() %>%
  filter(sr_cena == max(sr_cena, na.rm = TRUE))

# 19. Spo�r�d aut z silnikiem diesla wyprodukowanych w 2007 roku kt�ry model jest najta�szy?

auta %>%
  filter(Rodzaj.paliwa == "olej napedowy (diesel)", Rok.produkcji == 2007) %>%
  group_by(Model) %>%
  summarise(sr_cena = mean(Cena.w.PLN)) %>%
  ungroup() %>%
  filter(sr_cena == min(sr_cena, na.rm = TRUE))

# 20. Jakiego koloru auta maj� najwi�kszy medianowy przebieg?

auta %>%
  group_by(Kolor) %>%
  summarise(m_przebieg = median(Przebieg.w.km, na.rm = TRUE)) %>%
  ungroup() %>%
  filter(m_przebieg == max(m_przebieg, na.rm = TRUE))





