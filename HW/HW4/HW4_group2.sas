proc import datafile = 'c:\Users\dxk180020\desktop\pims.xls' 
out = pims
dbms = xls
replace; run;

proc contents data=pims; run;
proc print data=pims(obs=10); run;

/* 
model MS=qual plb price pion ef phpf plpf psc papc ncomp mktexp
model QUAL=price dc pion ef tyrp mktexp pnp
model PLB=dc pion tyrp ef pnp custtyp ncust custsize
model PRICE=MS qual dc pion ef tyrp mktexp pnp
model DC=MS qual pion ef tyrp penew cap rbvi emprody union
*/

/* Q1 */
proc syslin data=pims 2sls reduced; 
endogenous ms qual plb price dc; 
instruments pion ef phpf plpf psc papc ncomp mktexp tyrp pnp custtyp ncust custsize cap rbvi emprody union; 
MarketShare: model MS=qual plb price pion ef phpf plpf psc papc ncomp mktexp;
Quality: model QUAL=price dc pion ef tyrp mktexp pnp;
ProductLineBreadth: model PLB=dc pion tyrp ef pnp custtyp ncust custsize;
Price: model PRICE=MS qual dc pion ef tyrp mktexp pnp;
DirectCost: model DC=MS qual pion ef tyrp penew cap rbvi emprody union;
run;


/* Q2 */
PROC REG data=pims; 
MODEL MS=qual plb price pion ef phpf plpf psc papc ncomp mktexp / vif white stb; run;


/* Q4 */
proc syslin data=pims 3sls reduced; 
endogenous ms qual plb price dc; 
instruments pion ef phpf plpf psc papc ncomp mktexp tyrp pnp custtyp ncust custsize cap rbvi emprody union; 
MarketShare: model MS=qual plb price pion ef phpf plpf psc papc ncomp mktexp;
Quality: model QUAL=price dc pion ef tyrp mktexp pnp;
ProductLineBreadth: model PLB=dc pion tyrp ef pnp custtyp ncust custsize;
Price: model PRICE=MS qual dc pion ef tyrp mktexp pnp;
DirectCost: model DC=MS qual pion ef tyrp penew cap rbvi emprody union;
run;
