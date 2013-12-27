function [iclosest,distance]=phy_icp2(model,data)

iclosest=zeros(size(data,2));
distance=ones(size(data,2))*inf;
iclosest(1)=1;
distance(1)=norm(model(:,1)-data(:,1));
if size(data,2)>=2
    for i=1:size(data,2)
        for j=1:size(model,2)
            dist=norm(data(:,i)-model(:,j));
            if dist<=distance(i)
                distance(i)=dist;
                iclosest(i)=j;
            end
        end
    end
end