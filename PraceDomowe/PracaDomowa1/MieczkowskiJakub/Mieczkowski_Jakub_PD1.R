library(dplyr)
library(readr)
library(stats)
house_data <- read.csv("Szkola/Kuba/Studia/rstudio/house_data.csv")
View(house_data)

# 1. Jaka jest �rednia cena nieruchomo�ci po�o�onych nad wod�, kt�rych jako�� wyko�czenia jest r�wna lub wi�ksza od mediany jako�ci wyko�czenia?
# ja to rozumiem tak �e mediana jako�ci wyko�czenia tyczy si� te� tych po�o�onych nad wod�
(med <- median(house_data[house_data$waterfront == 1, c("grade")]))
house_data %>% 
  filter(waterfront == 1, grade>= med) %>% 
  summarise(srednia = mean(price))
# Odp: 2302236


# 2. Czy nieruchomo�ci o 2 pi�trach maj� wi�ksz� (w oparciu o warto�ci mediany) liczb� �azienek ni� nieruchomo�ci o 3 pi�trach?
house_data %>%
  filter(floors ==2 | floors==3) %>% 
  group_by(floors) %>%
  summarise(mediana = median(bathrooms))
  

# Odp: maj� tak� sam� median� liczby �azienek = 2.5


# 3. O ile procent wi�cej jest nieruchomo�ci le�cych na p�nocy zach�d ni�  nieruchomo�ci le��cych na po�udniowy wsch�d?
house_data %>% 
  summarise(sr_dlugosc= mean(long)) %>% 
  head(1)[1,1] ->sr_dlugosc

house_data %>% 
  summarise(sr_szerokosc = mean(lat)) %>% 
  head(1)[1,1] ->sr_szerokosc

#p�nocny zach�d
house_data %>% 
  filter(long < sr_dlugosc, lat > sr_szerokosc) %>% 
  summarize(ile = n()) %>% 
  head(1)[1,1] -> pnzach
 
#po�udniowy wsch�d 
house_data %>% 
  filter(long > sr_dlugosc, lat < sr_szerokosc) %>% 
  summarize(ile = n()) %>% 
  head(1)[1,1] -> pdwsch  
(odp <- 100*pnzach/pdwsch - 100)
# Odp: 29.66597


# 4. Jak zmieniała się (mediana) liczba łazienek dla nieruchomości wybudownych w latach 90 XX wieku względem nieruchmości wybudowanych roku 2000?
house_data %>% 
  filter(yr_built>=1990 , yr_built<=1999) %>% 
  summarise(med1 = median(bathrooms, na.rm = TRUE))

house_data %>% 
  filter(yr_built==2000) %>% 
  summarise(med2 = median(bathrooms, na.rm=TRUE))


# Odp: nie zmieni�a si�, wynosi 2,5


# 5. Jak wygl�da warto�� kwartyla 0.25 oraz 0.75 jako�ci wyko�czenia nieruchomo�ci po�o�onych na p�nocy bior�c pod uwag� czy ma ona widok na wod� czy nie ma?
house_data %>% 
  filter(lat > sr_szerokosc) %>% 
  group_by(waterfront) %>% 
  summarise(q = quantile(grade, c(0.25,0.75), na.rm = TRUE))
  

# Odp: Q1 nad wod�: 8, Q3 nad wod�: 11, Q1 nie nad wod�: 7, Q3 nie nad wod�: 8


# 6. Pod kt�rym kodem pocztowy jest po�o�onych najwi�cej nieruchomo�ci i jaki jest rozst�p miedzykwartylowy dla ceny nieruchomo�ci po�o�onych pod tym adresem?
house_data %>% 
  group_by(zipcode) %>% 
  summarise(ile = n()) %>% 
  arrange(-ile) %>% 
  head(1)[1,1] -> maxkod
house_data %>% 
  filter(zipcode == maxkod) %>% 
  summarise(q = quantile(price, seq(0.25, 0.75, 0.5), na.rm = TRUE)) ->kwantyle
(rozst�p <- kwantyle[2,1] - kwantyle[1,1])
# Odp: Najwi�cej nieruchomo�ci jest pod kodem 98103, rozst�p wynosi 262875


# 7. Ile procent nieruchomo�ci ma wy�sz� �redni� powierzchni� 15 najbli�szych s�siad�w wzgl�dem swojej powierzchni?
#patrz� na powierzchni� mieszkaln� bez ogrodu
house_data %>% 
  filter(sqft_living < sqft_living15) %>% 
  summarise(n = n()) %>% 
  head(1)[1,1] ->df
(ileproc<- df/dim(house_data)[1]*100)

# Odp: 42.59473%


# 8. Jak� liczb� pokoi maj� nieruchomo�ci, kt�rych cena jest wi�ksza ni� trzeci kwartyl oraz mia�y remont w ostatnich 10 latach (pamietaj�c �e nie wiemy kiedy by�y zbierane dane) oraz zosta�y zbudowane po 1970?
#jako liczb� pokoi traktuje sum� sypialni i �azienek bo o innych pokojach nie ma �adnych informacji
house_data %>% 
  summarise(q = quantile(price, 0.75, na.rm = TRUE)) %>% 
  head(1)[1,1] -> q3
house_data %>% 
  summarise(m = max(yr_renovated, na.rm=TRUE)) %>% 
  head(1)[1,1] ->ostrok
house_data %>% 
  filter(price > q3, yr_built>1970, yr_renovated>= ostrok-10) %>% 
  mutate(suma_pokoi = bathrooms + bedrooms) %>% 
  summarize(suma = sum(suma_pokoi, na.rm=TRUE))
  
# Odp: 166.75


# 9. Patrz�c na definicj� warto�ci odstaj�cych wed�ug Tukeya (wykres boxplot) wska� ile jest warto�ci odstaj�cych wzgl�dem powierzchni nieruchomo�ci(dolna i g�rna granica warto�ci odstajacej).
#dolna: 4Q1 - 3Q3, g�rna:4Q3 - 3Q1
#rozwa�am powierzni� z ogrodem
house_data %>% 
  summarise(q = quantile(sqft_lot, seq(0.25, 0.75, 0.5), na.rm = TRUE)) -> kw
Q1 <- kw[1,1]
Q3 <- kw[2,1]
dolna <- 4*Q1 - 3*Q3
g�rna <- 4*Q3 - 3*Q1
house_data %>% 
  filter(sqft_lot < dolna) %>% 
  summarise(n = n())
  
house_data %>% 
  filter(sqft_lot > g�rna) %>% 
  summarise(n = n())

# Odp: 0 odstaj�cych z do�u i 1771 odstaj�cych z g�ry


# 10. W�r�d nieruchomo�ci wska� jaka jest najwi�ksz� cena za metr kwadratowy bior�c pod uwag� tylko powierzchni� mieszkaln�.
#uwaga: dane s� w stopach na metr kwadratowy

house_data %>% 
  mutate(sqm_living = sqft_living*0.093) %>% 
  transmute(cena_metr = price/sqm_living) %>% 
  arrange(-cena_metr) %>% 
  head(1)


# Odp: 8711.171