# Impact Evaluation Methods - Replication Studies

## Description
Replication of causal inference methods from published papers in development economics, covering all major impact evaluation techniques.

## Papers Replicated

### RCT Analysis
**Paper**: "Does Information Break the Political Resource Curse? Experimental Evidence from Mozambique"  
**Authors**: Armand, Coutts, Vicente, Vilela (2020)  
**Methods**: 
- Treatment effect estimation with multiple treatment arms
- Balance tests (Table B2)
- Robustness checks (without lagged controls)
- Coefplot visualization (Figure 2)

### Other Methods
- **Regression Discontinuity Design (RDD)**
- **Difference-in-Differences (DiD)**
- **Propensity Score Matching (PSM)**
- **Instrumental Variables (IV)**

## Key Features

- Complete replication code for published results
- Balance tests and validity checks
- Multiple robustness specifications
- Professional visualization (coefplot)
- Control variable grouping with globals
- Clustered standard errors

## Technical Implementation
```stata
// Treatment effects with controls
reg outcome tc1 tc2 $controls $fixed_effects L.outcome, cl(cluster_var)

// Balance tests
iebaltab varlist, grpvar(treatment) stats(mean sd) rowvarlabels ///
         savetex(balance_table.tex)

// Visualization
coefplot (model1) (model2), keep(tc1 tc2) vertical yline(0)
```

## Skills Demonstrated
- Academic paper replication
- Multiple treatment arms
- Lagged dependent variables
- Complex control structures
- Publication-quality tables

## Author
Tchiofouo Yemelo Bruel
