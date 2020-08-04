function rate = pass_rate(gamma_map,reference,max_data);
I = [];
for i =3;
    I(1) = sum(sum(sum(gamma_map(reference.data > 0.1*max(max_data,[],'all'))>1)));
end  
II = I/(size(reference.data,1)*size(reference.data,2)*size(reference.data,3));
II = I/sum(sum(sum(gamma_map(reference.data > 0.1*max(max_data,[],'all')) >0)));
rate = (1-II)*100;

end