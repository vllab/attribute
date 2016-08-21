function [im, maxlabel] = seamcarving(im, maxlabel, per_init, per_final)
%% illustrative example of Seam carving for content aware image resizing(editing)

demo=nargout==0;

LABELO = zeros(size(im));
for i = 1:size(maxlabel, 1)
    for j = 1:size(maxlabel, 2)
        
        if maxlabel(i, j) == 2
            LABELO(i, j, 1) = 6; LABELO(i, j, 2) = 156; LABELO(i, j, 3) = 207;
        elseif maxlabel(i, j) == 3
            LABELO(i, j, 1) = 173; LABELO(i, j, 2) = 196; LABELO(i, j, 3) = 121;
        elseif maxlabel(i, j) == 4
            LABELO(i, j, 1) = 244; LABELO(i, j, 2) = 251; LABELO(i, j, 3) = 11;
        else
            LABELO(i, j, 1) = 54; LABELO(i, j, 2) = 41; LABELO(i, j, 3) = 134;
        end
    end
end
imwrite(uint8(LABELO), 'result/labelmap.png');
%% initialize
seam_used = 0; % number of seam
im=im2double(im);
[R, C, ~] = size(im);
per_cur = per_init;

load('GlobalLabelPrior.mat');

%% seam carving for each label (deletion first, then addition)
%% case of decrease
for LABEL_INDEX = 2:4
    
    BeFliped = 0;
    if per_final(LABEL_INDEX) - per_init(LABEL_INDEX) < 0
        
        NoCandid = 0;
        while per_final(LABEL_INDEX) - per_cur(LABEL_INDEX) < 0
            
            if BeFliped == 1
                im = fliplr(im);
                maxlabel = fliplr(maxlabel);
                GlobalPrior = fliplr(GlobalPrior);
                BeFliped = 2;
            end
            
            %G=costfunction(im);
            [G, ~] = imgradient(rgb2gray(im));
            D = bwdist(edge(maxlabel));
            % find shortest path in G
            Pot=G;
            %figure; imagesc(Pot, [0 5]);
            
            % weighted sum ver 1.0
            for i = 1:size(Pot, 1)
                for j = 1:size(Pot, 2)
                    if maxlabel(i, j) ~= LABEL_INDEX
                        Pot(i, j) = Pot(i, j)*5;
                    end
                end
            end
            
            %figure; imagesc(Pot, [0 5]);
            % weighted sum ver 2.0
            for i = 1:size(Pot, 1)
                for j = 1:size(Pot, 2)
                    if D(i, j) < 10
                        Pot(i, j) = Pot(i, j) + 0.25*(10-D(i, j));
                    end 
                end
            end
            %figure; imagesc(Pot, [0 5]);
%             for i = 1:size(Pot, 1)
%                 for j = 1:size(Pot, 2)
%                     if LABEL_INDEX == 2
%                         Pot(i, j) = Pot(i, j) + 5*(1-GlobalPrior(i, j, 1));
%                     elseif LABEL_INDEX == 4
%                         Pot(i, j) = Pot(i, j) + 5*(1-GlobalPrior(i, j, 2));
%                     elseif LABEL_INDEX == 3
%                         Pot(i, j) = Pot(i, j) + 5*(1-GlobalPrior(i, j, 3));
%                     end
%                 end
%             end
                        
            for ii=2:size(Pot,2)
                pp=Pot(:, ii-1);
                ix=pp(1:end-1)<pp(2:end);
                pp([false; ix])=pp(ix);
                ix=pp(2:end)<pp(1:end-1);
                pp(ix)=pp([false; ix]);
                Pot(:, ii)=Pot(:, ii)+pp;
            end
            
            while 1
                %candid_call = 0;
                candid_pool = zeros(size(Pot, 1), 2);
                candid_count = 0;
                pix=zeros(1, size(G,2));
                
                for i = 1:size(Pot, 1)
                    if maxlabel(i, 1) == LABEL_INDEX
                        candid_count = candid_count + 1;
                        candid_pool(candid_count, 1) = Pot(i, 1);
                        candid_pool(candid_count, 2) = i;
                    end
                end
                
                if candid_count ~= 0
                    [~, T] = min(candid_pool(1:candid_count, 1));
                    
                    target = candid_pool(T, 2);
                    pix(end) = target;
                    mn = Pot(target, end);
                    break;
                elseif BeFliped == 0 % can not find the candidate, flip the image to find seams on the other side
                    BeFliped = 1;
                    disp('Can not find the candidate, flip the image to find seams on the other side');
                    continue;
                elseif BeFliped ~= 0 % can not find the candidate on both side, quit
                    NoCandid = 1;
                    break;
                end
            end
            
            
%             while 1
%                 target = ceil(rand*size(maxlabel, 1));
%                 %[~, target] = min(candid_pool);
%                 if maxlabel(target, end) == LABEL_INDEX
%                     pix=zeros(1, size(G,2));
%                     pix(end) = target;
%                     mn = Pot(target, end);
%                     break;
%                 else
%                     candid_call = candid_call + 1;
%                 end
%                 
%                 if candid_call > 50 && BeFliped == 0 % can not find the candidate, flip the image to find seams on the other side
%                     BeFliped = 1;
%                     disp('The image is fliped.');
%                     continue;
%                 elseif candid_call > 50 && BeFliped ~= 0 % can not find the candidate on both side, quit
%                     NoCandid = 1;
%                     break;
%                 end
%             end
                        
            if NoCandid == 1
                disp('No candidate remains, quit.');
                break;
            end
            
            pp=find(Pot(:, end)==mn);
            pix(end)=pp(ceil(rand*length(pp)));
            
            im(pix(end), end, :)=nan;
            for ii=size(G,2)-1:-1:1
                [mn,gg]=min(Pot(max(pix(ii+1)-1,1):min(pix(ii+1)+1,end), ii));
                pix(ii)=gg+pix(ii+1)-1-(pix(ii+1)>1);
                im(pix(ii),ii,:)=bitand(ii,1);
            end
            imshow(im);
            
            %remove seam from im & G:
            for ii=1:size(im,2)
                im(pix(ii):end-1,ii,:)=im(pix(ii)+1:end,ii,:);
                GlobalPrior(pix(ii):end-1,ii,:)=GlobalPrior(pix(ii)+1:end,ii,:);
                maxlabel(pix(ii):end-1, ii) = maxlabel(pix(ii)+1:end, ii);
            end
            im(end, :, :) = [];
            maxlabel(end, :) = [];
            GlobalPrior(end, :, :) = [];
            
            % calculate new percetange of labels
            label_count = zeros(size(per_init));
            for i = 1:size(maxlabel, 1)
                for j = 1:size(maxlabel, 2)
                    label_count(maxlabel(i, j)) = label_count(maxlabel(i, j)) + 1;
                end
            end
            
            seam_used = seam_used+1;
            per_cur(:) = label_count(:) / (R*C);
            disp(per_cur(2:4)');
        end

    end
    
    if BeFliped == 2 % flip the fliped image again to recover it for next step
        im = fliplr(im);
        maxlabel = fliplr(maxlabel);
        GlobalPrior = fliplr(GlobalPrior);
    end
end


%% case of increase
for LABEL_INDEX = 2:4
    if per_final(LABEL_INDEX) - per_init(LABEL_INDEX) > 0      
        
        result = im;
        if seam_used > 0
            pix = zeros(seam_used, size(result, 2));
        end
        
        
        for jj=1:seam_used
           %G=costfunction(im);
            [G, ~] = imgradient(rgb2gray(im));
            D = bwdist(edge(maxlabel));
            % find shortest path in G
            Pot=G;
            
            % weighted sum ver 1.0
            for i = 1:size(Pot, 1)
                for j = 1:size(Pot, 2)
                    if maxlabel(i, j) ~= LABEL_INDEX
                        Pot(i, j) = Pot(i, j)*5;
                    end
                end
            end
            
            for i = 1:size(Pot, 1)
                for j = 1:size(Pot, 2)
                    if D(i, j) < 10
                        Pot(i, j) = Pot(i, j)*(10-D(i, j));
                    end
                end
            end
            % weighted sum ver 2.0
%             for i = 1:size(Pot, 1)
%                 for j = 1:size(Pot, 2)
%                     if LABEL_INDEX == 2
%                         Pot(i, j) = Pot(i, j) + 1.5*GlobalPrior(i, j, 1);
%                     elseif LABEL_INDEX == 4
%                         Pot(i, j) = Pot(i, j) + 1.5*GlobalPrior(i, j, 2);
%                     elseif LABEL_INDEX == 3
%                         Pot(i, j) = Pot(i, j) + 1.5*GlobalPrior(i, j, 3);
%                     end
%                 end
%             end
                       
            for ii=2:size(Pot,2)
                pp=Pot(:, ii-1);
                ix=pp(1:end-1)<pp(2:end);
                pp([false; ix])=pp(ix);
                ix=pp(2:end)<pp(1:end-1);
                pp(ix)=pp([false; ix]);
                Pot(:, ii)=Pot(:, ii)+pp;
            end
            
            check = 0;
            while ~check
                target = ceil(rand*size(maxlabel, 1));
                if maxlabel(target, end) == LABEL_INDEX
                    pix(jj, end) = target;
                    %mn = Pot(end, target);
                    check = 1;
                end
            end
            
            %     pp=find(Pot(end,:)==mn);
            %     pix(end, jj)=pp(ceil(rand*length(pp)));
            
            im(pix(jj, end),end,:)=nan;
            for ii=size(G,2)-1:-1:1
                [mn,gg]=min(Pot(max(pix(jj, ii+1)-1,1):min(pix(jj, ii+1)+1, end), ii));
                pix(jj, ii)=gg+pix(jj, ii+1)-1-(pix(jj, ii+1)>1);
                im(pix(jj, ii),ii,:)=bitand(ii,1);
            end
            
        end
        
        
        for seam_index = 1:size(pix, 1)
            
            disp(seam_index);
            
            newRow3 = zeros(1, size(im, 2), 3);
            newRow = zeros(1, size(im, 2), 1);
            result = [result; newRow3];
            maxlabel = [maxlabel; newRow];
            
            %add seam from im & G:
            for ii=1:size(result,2)                
                % three cases for adding a seam
                result(pix(seam_index, ii)+1:end, ii, :) = result(pix(seam_index, ii):end-1, ii, :);
                maxlabel(pix(seam_index, ii)+1:end, ii) = maxlabel(pix(seam_index, ii):end-1, ii);
                
                if pix(seam_index, ii) <= 3
                    result(pix(seam_index, ii), ii, :) = result(pix(seam_index, ii)+1, ii, :);
                    maxlabel(pix(seam_index, ii), ii) = maxlabel(pix(seam_index, ii)+1, ii);
                    
                elseif pix(seam_index, ii) >= size(result, 1)-3
                    result(pix(seam_index, ii), ii, :) = result(pix(seam_index, ii)-1, ii, :);
                    maxlabel(pix(seam_index, ii), ii) = maxlabel(pix(seam_index, ii)-1, ii);
                else
                    
                    S = rand();
                    if S >= 0.5
                        result(pix(seam_index, ii), ii, :) = result(pix(seam_index, ii)+1, ii, :);
                        maxlabel(pix(seam_index, ii), ii) = maxlabel(pix(seam_index, ii)+1, ii);
                    else
                        result(pix(seam_index, ii), ii, :) = result(pix(seam_index, ii)-1, ii, :);
                        maxlabel(pix(seam_index, ii), ii) = maxlabel(pix(seam_index, ii)-1, ii);
                   end
                    
%                     result(pix(seam_index, ii), ii, :) = (result(pix(seam_index, ii)+1, ii, :) + result(pix(seam_index, ii)-1, ii, :))/2;
%                     maxlabel(pix(seam_index, ii), ii) = maxlabel(pix(seam_index, ii)+1, ii);
                end
                
                % modify the position of other seams
                for aa = seam_index+1:size(pix, 1)
                    if pix(aa, ii) >= pix(seam_index, ii)
                        pix(aa, ii) = pix(aa, ii)+1;
                    end
                end               
            end
            
            % calculate new percetange of labels
            label_count = zeros(size(per_init));
            for i = 1:size(maxlabel, 1)
                for j = 1:size(maxlabel, 2)
                    label_count(maxlabel(i, j)) = label_count(maxlabel(i, j)) + 1;
                end
            end
            
            per_cur(:) = label_count(:) / (R*C);
            disp(per_cur(2:4)');
            
            % if the percentage of this label is achieved,
            % quit and calculate the remained number of seam for other
            % labels
            if per_final(LABEL_INDEX) - per_cur(LABEL_INDEX) < 0
                seam_used = seam_used - seam_index;
                break;
            end
        end
        
        im = result;
    end
    
end

imwrite(im, 'result/result.png');
end



function G=costfunction(im) %%(xi,yi)
G=zeros(size(im,1),size(im,2));
for ii=1:size(im,3)
    %G=G+abs(filter2([1 0 -1],im(:,:,ii)))+abs(filter2([1;0;-1],im(:,:,ii)));
    G=G+(filter2([.5 1 .5; 1 -6 1; .5 1 .5],im(:,:,ii))).^2; %faster and reasonably good.
end
end
