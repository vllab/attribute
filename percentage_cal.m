function per_init = percentage_cal(maxlabel)
% calculate the percentage of each label from the input image

per_init = zeros(4, 1);

for index = 2:4
    count = 1;
    for i = 1:size(maxlabel, 1)
        for j = 1:size(maxlabel, 2)
            
            if maxlabel(i, j) == index
                count = count+1;
            end
        end
    end
    per_init(index, 1) = (count-1) / (size(maxlabel, 1)*size(maxlabel, 2));
    
    clear data;
end

end

