%Dette program er skrevet af Thomas B�low foraaret 2007, og beregner middelv�rdi
%og spredning af et vilk�rligt analytisk udtryk ved hj�lp af
%ophobningsloven. Du b�r selv tjekke om du mener at programmer er ok.
%Du bruger programmet ved at placere det i current directory, og s� efter
%prompten skrives: 
%[mean, stdev] = camas('(3*x^2)/t','t',[200,300],[15,18],'x',[23,17],[2,3])
%- eller tilsvarende for dine data.
% 10 maj 2007  Helge Knudsen

function [mean,stdev] = camas(expr,varargin)
%CAlculate Mean-value And Standard-deviation.
%Middelv�rdi og spredning beregnes af et vilk�rligt funktionsudtryk.
%[mean, stdev] = camas('(3*x^2)/t','t',[200,300],[15,18],'x',[23,17],[2,3])
number_of_variables = numel(varargin(1,:))/3;

%Her erkl�res variablerne fra inputtet symbolsk. F�rst skabes en streng p�
%formen "syms t x y z u ..." og den evalueres s�.
sym_str = 'syms';
for i=0:number_of_variables-1
    sym_str = [sym_str,' ',cell2mat(varargin(1,1+3*i))];
end
eval(sym_str);

%Her tages de partielle afledte mht. hver af variablene og de gemmes i et
%cell-array. Det var n�dvendigt at g�re ved f�rst at lave en streng og
%derefter evaluere den, da "eval" af "varargin()" ikke virkede inde i
%"diff"-kaldet.
for i=0:number_of_variables-1
    microstring=['partial_derivative_tmp(i+1)=diff(',expr,',',cell2mat(varargin(1,1+3*i)) ,');'];
    eval(microstring);
    partial_derivative(i+1) = cellstr(vectorize(partial_derivative_tmp(i+1)));
end

for i=0:number_of_variables-1
    %Streng der tilordner mean-vektorerene til de respektive variabelnavne. (Der
    %dermed ikke l�ngere er symbolske.)
    superstring=[cell2mat(varargin(1,1+3*i)),'=','cell2mat(varargin(1,2+3*i));'];
    eval(superstring);
end
mean=eval(vectorize(expr));
stdev_squared=0;
for i=0:number_of_variables-1
    stdev_squared=stdev_squared +eval(cell2mat(partial_derivative(i+1))).^2 .* cell2mat(varargin(1,3+3*i)).^2;
end
stdev=sqrt(stdev_squared);

% format short g
% disp('Partialderivatives:');
% disp(partial_derivative);
% disp('Mean:');
% disp(mean);
% disp('stdev:');
% disp(stdev);