function [DM] = distMAT(train, test)

[train_row, train_col] = size(train);
[test_row, test_col] = size(test);

DM = zeros(train_row, test_row);

ts=sum(train');
for i=1:train_col; 
    train(:,i)=train(:,i)./ts';
end;

ts=sum(test');
for i=1:test_col; 
    test(:,i)=test(:,i)./ts';
end;

train(train==0)=0.0000001;
test(test==0)=0.0000001;

for i = 1:train_row,
    t1=ones(test_row,1)*train(i,:);
    DM(i,:) = sum((-test.*log(t1))');
end

