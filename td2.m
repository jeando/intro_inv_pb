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
    w=5*n;
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
  %          [ psim, weight] = similar_patches(img, w,x,y,pref,k,alpha);
  %          un_sur_somme_w = 1/sum(weight);
  %          weight=weight*un_sur_somme_w;
           % disp(un_sur_somme_w);
           % disp(psim);
           % disp(size(psim));
   %         tmp = psim(1:n,1:n);
   %         for ii = 1 : k-1
   %             tmp = tmp + psim(1:n,(ii*n+1):((ii+1)*n)) * weight(ii+1);
   %         end
            img2(y,x) = similar_patches(img, n, w,x,y,pref,k,alpha);%tmp((n+1)/2,(n+1)/2);

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
    %function [ psim, weight] = similar_patches(img, w,x,y,pref,k,alpha)
    function [ val] = similar_patches(img, n, w,x,y,pref,k,alpha)
        %n=size(pref,1);
      %  disp(n);
      %  all_patch = [];
        n_rows = min(y+(w-1)/2,size(img,1)-(n-1)/2)-max(y-(w-1)/2,1+(n-1)/2);
        all_norm = zeros((min(x+(w-1)/2,size(img,2)-(n-1)/2)-max(x-(w-1)/2,1+(n-1)/2))*n_rows,3);
       % weight = [];
      %  psim = [];
        for col = max(x-(w-1)/2,1+(n-1)/2) : min(x+(w-1)/2,size(img,2)-(n-1)/2)
            ccols = col - max(x-(w-1)/2,1+(n-1)/2);
            ccols_x_n_row = ccols*n_rows;
            for row = max(y-(w-1)/2,1+(n-1)/2) : min(y+(w-1)/2,size(img,1)-(n-1)/2)
                rrows = row - max(y-(w-1)/2,1+(n-1)/2);
                all_norm(ccols_x_n_row+rrows+1,:)=[sum(sum((pref-img((row-(n-1)/2):(row+(n-1)/2),( col-(n-1)/2):(col+(n-1)/2))).^2)),row,col];
            end
        end
        [sorted_value, indice] = sort(all_norm(:,1));
        row = all_norm(indice,2);
        col = all_norm(indice,3);
        tmp2 = zeros(n,n);
        un_sur_alpha_nn = 1/(alpha * n * n);
        weight = exp(-sorted_value(1:k)*un_sur_alpha_nn);
        total_weight_inv = 1/sum(weight);
        weight=weight*total_weight_inv;
        for i = 1 : k
            tmp2 = tmp2 + patch_extract(img,n,col(i),row(i))*weight(i);
            %psim(:,((i-1)*n+1):((i)*n)) = patch_extract(img,n,col(i),row(i));
        end
        val = tmp2((n+1)/2,(n+1)/2);
    end
end

