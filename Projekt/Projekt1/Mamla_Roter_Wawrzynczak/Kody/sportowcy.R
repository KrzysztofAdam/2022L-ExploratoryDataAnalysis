#otwieranie bazy danych
library(haven)

dataset = read_sav(path)
path = file.path("C:/Users/Darek/Documents", "R", "ROSES.sav")
dataset <- as.data.frame(dataset)

#SPORTOWCY##
library(data.table)
library(stringr)
library(dplyr)
library(ggplot2)

#szukam sportowc�w na podstawie odpowiedzi na pytanie o tym kim ucze� chce zosta� w przysz�osci

#wektor z s�owami zwi�zanymi ze sportem
sports <- c("SPORT","PI�KA", "SIATK","SZACH","BOKS","�WKA","P�YW")

sportsmen <- dataset %>%
  mutate(Upperstr = toupper(Q18_1)) %>% 
  filter((str_detect(Upperstr, sports[1])|(str_detect(Upperstr, sports[2]))
          |str_detect(Upperstr, sports[3])|str_detect(Upperstr, sports[4])
          |str_detect(Upperstr, sports[5])|str_detect(Upperstr, sports[6])
          |str_detect(Upperstr, sports[7]))
         & !(str_detect(Upperstr, "TRANSPORT")) & !(str_detect(Upperstr, "MEDYCYNY"))
         & !(str_detect(Upperstr, "DZIENNIK"))
  ) 


#mamy 58 sportowc�w

sportsmen <- sportsmen %>% 
  t() %>% 
  as.data.frame() %>% 
  t() %>% 
  as.data.frame()

#sumuje ilu sportowc�w ma dany stopie� zaufania wobec naukowc�w
#z uwzgl�dnieniem podzia�u na p�e�

science_ds_sportsmen <- sportsmen %>% 
  select(c(19,60,61,68:71,77:82,90,92:97,123,131,146:153,155,157)) %>% 
  mutate(P�e� = ifelse(Q2==1, 'Dziewczynka', 'Ch�opiec')) %>% 
  relocate(where(is.numeric), .after = where(is.character)) %>% 
  select(-2) %>% 
  na.omit(Q11_12) %>%
  t() %>% 
  t() %>% 
  as.data.frame() %>%
  group_by(P�e�, Q11_12) %>%
  summarise(Count = n()) %>% 
  ungroup() 

## uzupe�nienie ramki danych, dodanie informacji o tym �e
#�adna z dziewczynek-sportowc�w zaznaczy�a 3 i 4 w pytaniu o naukowc�w

additional_rows <-data.frame(
  "P�e�" = c("Dziewczynka","Dziewczynka"),
  "Q11_12" = c(as.character(" 3"),as.character(" 4")),
  "Count"=c(as.numeric(0.1),as.numeric(0.1)))

science_ds_sportsmen<- rbind(science_ds_sportsmen,additional_rows)
science_ds_sportsmen<- as.data.frame(science_ds_sportsmen)
colnames(science_ds_sportsmen) <- c('P�e�', 'Zaufanie', 'Zliczone' )


#     WYKRESY   #
# Wykres przedstawiajacy zaufanie sportowc�w w zale�no�ci od p�ci
# gdy s�upek przedstawia warto�� 0.1, to oznacza,�e rzeczywista
# warto�� wynosi 0, dzi�ki temu warto�ci 0 s� dobrze widoczne na wykresie

#wykres z podzia�em na p�cie

ggplot(science_ds_sportsmen, aes(x = Zaufanie, y = Zliczone, fill = P�e�)) +
  geom_bar(stat = "identity", position = "dodge")+
  labs(x = ' Zaufanie do naukowc�w', y = 'Ilo�� os�b', fill = 'P�e�',
       title = 'Zaufanie sportowc�w do naukowc�w')+
  theme_bw()+
  scale_x_discrete(labels = c('Brak', 'Niewielkie', '�rednie', 'Wysokie'))+
  scale_y_continuous(expand = expansion(mult =c(0,.02)),
                     limits = c(0, 16))+
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
  