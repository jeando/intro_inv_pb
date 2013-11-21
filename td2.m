function td2()
    close all;
    clear all;
    img=imread('peppers.png');
    img=double(img(:,:,1));
    disp(size(img));
    
    
    sigma_b = 7;
    b=sigma_b * randn(size(img));
    img = img + b;
    
    n=11;
    w=21;
    k=10;
    alpha=100;
    img2=img;
    for x=n:size(img,2)-n
        for y=n:size(img,1)-n
   % for x=150:200%size(img,2)-n
    %    for y=200:250%size(img,1)-n
    
   % disp(strcat('x:',int2str(x),', y: ',int2str(y)));
    %disp(size(img));
            pref = patch_extract(img, n, x, y);
            [ psim, weight] = similar_patches(img, w,x,y,pref,k,alpha);
            un_sur_somme_w = 1/sum(weight);
            weight=weight*un_sur_somme_w;
           % disp(un_sur_somme_w);
           % disp(psim);
           % disp(size(psim));
            tmp = psim(1:n,1:n);
            for i = 1 : k-1
                tmp = tmp + psim(1:n,(i*n+1):((i+1)*n)) * weight(i+1);
            end
            img2(y,x) = tmp(6,6);
        end
        disp(x);
    end
    
        figure;imagesc(img/255);
        colorbar;
        colormap(gray);
        figure;imagesc(img2/255);
        colorbar;
        colormap(gray);
    
    function pref = patch_extract(img, n,x,y)
       % disp(x);disp(y);
      % disp(n);
       %disp(strcat('x:',int2str(x),', y: ',int2str(y)));
        pref = img((y-(n-1)/2):(y+(n-1)/2),( x-(n-1)/2):(x+(n-1)/2));
    end
    function [ psim, weight] = similar_patches(img, w,x,y,pref,k,alpha)
        n=size(pref,1);
      %  disp(n);
      %  all_patch = [];
        all_norm = [];
        weight = [];
        psim = [];
        for col = max(x-(w-1)/2,1+(n-1)/2) : min(x+(w-1)/2,size(img,2)-(n-1)/2)
            for row = max(y-(w-1)/2,1+(n-1)/2) : min(y+(w-1)/2,size(img,1)-(n-1)/2)
                %disp(size(img,2)-(n+1)/2);
                tmp_patch = patch_extract(img,n,col,row);
                tmp_norm = sum(sum((pref-tmp_patch).^2));
                %all_patch = [all_patch, tmp_patch];
                all_norm = [all_norm; [tmp_norm,row,col]];
            end
        end
       % disp('toto');
        %disp(size(all_norm));
       % disp('toto2');
        %disp(all_norm(1,:));
        [sorted_value, indice] = sort(all_norm(:,1));
        row = all_norm(indice,2);
        col = all_norm(indice,3);
        %disp(col);
        %disp('azer');
        %disp(sorted_value);
        %disp('azedfghjr');
        for i = 1 : k
            weight = [weight, exp(-sorted_value(i)/(alpha*(n^2)))];
            psim = [psim,patch_extract(img,n,col(i),row(i))];
        end
        %disp(weight);
    end
end

