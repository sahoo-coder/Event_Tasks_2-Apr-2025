codeunit 50620 denySalesOrderPostingCodeunit
{
    //First Task
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnBeforePostSalesDoc, '', false, false)]
    local procedure MyProcedure(var SalesHeader: Record "Sales Header")
    var
        custLedEntry: Record "Cust. Ledger Entry";
        totalOverdueDays: Integer;
        totalDue: Decimal;
        totalCount: Integer;

    begin
        if SalesHeader."Document Type" = SalesHeader."Document Type"::Order then begin
            totalDue := 0;
            totalCount := 0;
            custLedEntry.Reset();
            custLedEntry.SetRange("Document Type", custLedEntry."Document Type"::Invoice);
            custLedEntry.SetRange("Customer No.", SalesHeader."Sell-to Customer No.");
            // custLedEntry.CalcFields("Remaining Amount");
            custLedEntry.SetFilter("Remaining Amount", '>0');
            if custLedEntry.FindSet() then
                repeat
                    totalOverdueDays := Today - custLedEntry."Due Date";
                    if (totalOverdueDays > 30) then begin
                        custLedEntry.CalcFields("Remaining Amount");
                        totalDue += custLedEntry."Remaining Amount";
                        totalCount += 1;
                    end;
                until custLedEntry.Next() = 0;

            if (totalCount >= 2) and (totalDue > 8000) then begin
                Error('You Have OverDue Amount Which is %1 and You have total %2 Records with Overdue Amount!', totalDue, totalCount);
            end;
        end;
    end;

    //Second Task
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Item", OnAfterCopyItem, '', false, false)]
    local procedure MyProcedure2(var CopyItemBuffer: Record "Copy Item Buffer"; SourceItem: Record Item; var TargetItem: Record Item)
    begin
        SourceItem.Reset();
        SourceItem.SetRange("No.", CopyItemBuffer."Source Item No.");
        TargetItem.Description := SourceItem.Description + '-Copied Item';
        TargetItem.Modify();
    end;

}