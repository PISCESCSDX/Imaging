function [std] = std2(input)
% Finds the standard deviation of an array
mean = 0;
for i = 1:size(input,1)
    for j = 1:size(input,2)
        mean = mean + input(i,j);
    end
end
mean = mean/(size(input,1)*size(input,2));

std = 0;
for i = 1:size(input,1)
    for j = 1:size(input,2)
        std = std +(input(i,j)-mean)^2;  
    end
end

std = sqrt(std/((size(input,1)*size(input,2))-1));


end

