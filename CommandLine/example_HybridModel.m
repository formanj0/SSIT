%% example_HybridModel
% In this script, we demonstrate how to adjust a model to treat some
% species (i.e., upstream reactions) using an ODE formulation, while having
% other species (i.e., downstream species) evolving in a discrete
% stochastic manner. 
close all
clear all

%% Example 1 - transcription and translation
% First create a full model (e.g., for mRNA and protein)
Model1 = SSIT;
Model1.species = {'rna','protein'};
Model1.initialCondition = [0;0];
Model1.propensityFunctions = {'kr';'gr*rna';'k2*rna';'g2*protein'};
Model1.stoichiometry = [1,-1,0,0;0,0,1,-1];
Model1.parameters = ({'kr',100;'gr',0.5;...
    'k2',2;'g2',1});
Model1.fspOptions.initApproxSS = false; 
Model1.tSpan = linspace(0,5,10);
[fspSoln1,Model1.fspOptions.bounds] = Model1.solve;
Model1.makePlot(fspSoln1,'marginals',[],[],[2,3])

%% Next, reduce it by assuming that the rna behaves deterministically 
Model2 = Model1;
Model2.useHybrid = true;
Model2.hybridOptions.upstreamODEs = {'rna'};
[fspSoln2, Model2.fspOptions.bounds] = Model2.solve;
Model2.makePlot(fspSoln2,'marginals',[],[],3)

%% Example 2 - 5-species MAPK induction Model
% In this example, we consider a model of MAPK trnaslocation to the nucleus
% followed by binding to a gene and then transcription activation.
Model3 = SSIT;
Model3.species = {'mapkCyt','mapkNuc','geneInactive','geneActive','rna'};
Model3.initialCondition = [50;0;1;0;0];
Model3.propensityFunctions = {'ktr1*mapkCyt';'ktr2*mapkNuc';'kb*mapkNuc*geneInactive';'ku*geneActive';'k*geneActive';'g*rna'};
Model3.stoichiometry = [-1,1,0,0,0,0;...
    1,-1,-1,1,0,0;...
    0,0,-1,1,0,0;...
    0,0,1,-1,0,0;...
    0,0,0,0,1,-1];
Model3.parameters = ({'ktr1',1;'ktr2',2;...
    'kb',2;'ku',20;...
    'k',20;'g',1});
Model3.fspOptions.initApproxSS = false; 
Model3.tSpan = linspace(0,5,10);
[fspSoln3,Model3.fspOptions.bounds] = Model3.solve;
Model3.makePlot(fspSoln3,'marginals',[],[],[11:15])

%% Reduced model where only the RNA species is stochastic
Model4 = Model3;
Model4.useHybrid = true;
Model4.hybridOptions.upstreamODEs = {'mapkCyt','mapkNuc','geneInactive','geneActive'};
[fspSoln4, Model4.fspOptions.bounds] = Model4.solve;
Model4.makePlot(fspSoln4,'marginals',[],[],15)

%% Reduced model where only the gene and RNA species are stochastic.
% In this example, you will recieve a warning telling you that one of the
% reactions changes both the upstream and downstream species.  This is not
% allowed, and the code will then automatically delete the upstream effect
% (in this case the change of active MAPK) from the stoichiometry for the
% downstream reaction. This will introduce an additional approximation
% error.
Model5 = Model3;
Model5.useHybrid = true;
Model5.hybridOptions.upstreamODEs = {'mapkCyt','mapkNuc'};
[fspSoln5, Model5.fspOptions.bounds] = Model5.solve;
Model5.makePlot(fspSoln5,'marginals',[],[],[13,14,15])

