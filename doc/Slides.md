---

title : (Big) Data Analytics for Business
subtitle : Segmentation in the Boating Industry
author : T. Evgeniou and J. Niessing
job : INSEAD
widgets : []
mode : selfcontained 

---

## What is Dimensionality Deduction and Factor Analysis?

Derive new data variables which are linear combinations of the original ones and capture most of the information in the data. 

Is typically used as a first step in Data Analytics

Can also be used to solve multicollinearity issues in regression.

---

## Factor Analysis: Key idea


1. Transform the original variables (ONLY the x's) into a smaller set of factors

2. Understand the underlying structure of the data and the new factors

3. Use the factors for subsequent analysis



```
## Error: could not find function "readPNG"
```

```
## Error: could not find function "grid.raster"
```


---

## Key Questions

1. Can we really simplify the data by grouping the columns?

2. How many factors should we use?

3. How good are the factors we found?

4. How interpretable are the factors we found? 

---

## Dimensionality Reduction and Factor Analysis: 8 (Easy) Steps

1. Confirm the data are metric (interval scale) 

2. Decide whether to scale standardize the data

3. Check the correlation matrix to see if Factor Analysis makes sense

4. Develop a scree plot and decide on the number of factors to be derived

5. Interpret the factors and Consider rotation of factors (technical but useful)

6. Save factor scores for subsequent analyses

---

## Applying Factor Analysis: Evaluating MBA Applications

Variables available:
* GPA
* GMAT score
* Scholarships, fellowships won
* Evidence of Communications skills 
* Prior Job Experience
* Organizational Experience
* Other extra curricular achievements

Which variables do you believe correlate with  each other?
What do these variables capture?

---

## Step 1: Confirm the data are metric (interval scale) 


```
Error: could not find function "xtable"
```


---

## Step 2: Decide whether to scale standardize the data


```
Error: object 'ProjectData' not found
```

```
Error: could not find function "xtable"
```


---

## Step 3:  Check correlation matrix to see if Factor Analysis makes sense


```
Error: could not find function "corstars"
```

```
Error: could not find function "xtable"
```

** = correlation is significant at 1% level; * = correlation is significant at 5% level

#### Even if the data is not as neatly correlated as here, Factor analysis can be helpful

---

## Step 4. Develop a scree plot and decide on the number of factors to be derived

* Factors
  * If there are n variables we will have n factors in total
  * First factor will explain most variance, second next and so on.

* Variance Explained by Factors
  * with standardized variables each variable has a variance of 1, so the total variance in n variables is n
  * each factor will have an associated eigen value which is the amount of variance explained by that factor

--- 

## Example Factors


```
Error: could not find function "principal"
```

```
Error: object 'Unrotated_Results' not found
```

```
Error: object 'Unrotated_Factors' not found
```

```
Error: object 'Unrotated_Factors' not found
```

```
Error: object 'Unrotated_Factors' not found
```

```
Error: could not find function "xtable"
```


--- 

## How Many Factors? Eigenvalues and Variance Explained


```
Error: could not find function "PCA"
```

```
Error: object 'Variance_Explained_Table_results' not found
```

```
Error: could not find function "xtable"
```


--- 

## How Many Factors? Scree Plot


```
Error: object 'Unrotated_Results' not found
```

```
Error: object 'eigenvalues' not found
```

```
Error: could not find function "minor.tick"
```

```
Error: plot.new has not been called yet
```


--- 

## How many factors?

* The maximal number of factors is the number of original variables Eigenvalue>1
* "Elbow" in the Scree plot
* Cumulative variance explained

---

## Step 5. Interpret the factors and Consider rotation of factors (technical but useful)

Rotated Factors


```
Error: could not find function "principal"
```

```
Error: object 'Rotated_Results' not found
```

```
Error: object 'Rotated_Factors' not found
```

```
Error: object 'Rotated_Factors' not found
```

```
Error: object 'Rotated_Factors' not found
```

```
Error: could not find function "xtable"
```


---

## What Factor Loads "Look Good"? Three Quality Criteria

1. For each factor (column) only a few loadings are large (in absolute value)

2. For each initial variable (row) only a few loadings are large (in absolute value)

3. Any pair of factors (columns) should have different "patterns" of loading

---

## Step 6. Save factor scores for subsequent analyses



```
Error: object 'Rotated_Results' not found
```

```
Error: object 'NEW_ProjectData' not found
```

```
Error: could not find function "xtable"
```


---

## Using the Factor Scores: Pereptual Maps


```
Error: object 'NEW_ProjectData' not found
```



## Factor Analysis: Key (Technical) Notions 

1. Correlation
2. Variance explained (eigenvalues)
3. Scree plot
4. Varimax rotation
5. Factor Loadings ("components")
6. Factor scores

---

## Next Class: Cluster Analysis for Segmentation
