library('scidb')
scidbconnect()

################################
#Inner Join and Merge
left = build("double(i*j)", dim=c(3,3), names=c("a","i","j"))
str(left)
left = subset(left, i==2)
head(left)

right = build("double(2*i*j)", dim=c(3,3), names=c("a","i","j"))
right = subset(right, j==1)
head(right)
head(merge(left, right, equi_join=FALSE))
head(merge(left, right, merge=TRUE))

################################
#Slicing with Cross Joins
left = build("double(random())", dim=c(3,3),
         names=c("a","i","j"))
str(left)
right = as.scidb(c("a","b","c"))
str(right)
right[]

merge(left, subset(right, val=="a" || val == "c"),
              equi_join=FALSE)[]
merge(left, subset(right, val=="a" || val == "c"),
               equi_join=FALSE, by.x="j", by.y="i")[]

################################
#Matrix Centering with Cross Joins
m = build("random()", dim=c(5,10), names=c("a","i","j"))
m = scidbeval(m)
str(m)
head(m)

colmeans = aggregate(m, FUN="avg(a) as cm", by="j")
str(colmeans)
head(colmeans)

join_result = merge(m, colmeans, equi_join=FALSE)
str(join_result)
head(join_result, n=15)
centered = transform(join_result, ca=a-cm)
str(centered)
centered = project(centered, "ca")
head(centered)

#Or just this!
centered = project(transform(merge(m, aggregate(m, FUN="avg(a) as cm", by="j")), ca=a-cm), "ca")

################################
#Partial Product Joins
left <- build("double(random())", dim=c(5,5),
                names=c("a","i","j"))
str(left)
head(left)
right <- build("ABC", dim=c(5,5), names=c("b","j","k"))
result <- merge(left, right, equi_join = FALSE)
str(result)
head(result)

################################
#Inner Equi Joins
left = as.scidb(c('a','b','c','d','e','f'))
right = as.scidb(
    data.frame(val   =c('b','b','x','e'),
               number=c( 1,  2,  3,  4 )),
    types=c("string","int64"))
merge(left, right, by="val")[]

#Outer:
merge(left, right, by="val", all.x=1)[]
merge(transform(left, ival="i"), right, by="val", all.y=1)[]
