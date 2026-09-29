public class OpportunityHelper {

    /**
     * Keeps account revenue in sync with sales results.
     * When an opportunity is Closed Won, its Amount is added to the
     * AnnualRevenue of the related Account, so account-level revenue
     * reporting reflects newly won deals.
     * @param opps Opportunities that were created or updated
     */
    public static void updateAccountRevenue(List<Opportunity> opps) {
        for (Opportunity opp : opps) {
            Account acc = [SELECT Id, AnnualRevenue FROM Account WHERE Id = :opp.AccountId];

            if (opp.StageName == 'Closed Won') {
                acc.AnnualRevenue = acc.AnnualRevenue + opp.Amount;
                update acc;
            }
        }
    }

    /**
     * Filters out low-value deals from a working list.
     * Sales management only wants to review opportunities worth
     * 1,000 or more, so any opportunity below that threshold is
     * removed from the list before it is processed further.
     * @param opps The list of opportunities to filter (modified in place)
     */
    public static void removeSmallDeals(List<Opportunity> opps) {
        for (Integer i = 0; i < opps.size(); i++) {
            if (opps[i].Amount < 1000) {
                opps.remove(i);
            }
        }
    }

    /**
     * Builds a short text summary of the product line items for each opportunity.
     * For every given opportunity, it counts the line items and totals their value,
     * so the summary can be shown or sent anywhere without opening the record.
     * @param oppIds Ids of the opportunities to summarize
     * @return Map of Opportunity Id to its summary text
     */
    public static Map<Id, String> summarizeLineItems(Set<Id> oppIds) {
        List<Opportunity> oppList = [
            SELECT Id, Name
            FROM Opportunity
            WHERE Id IN :oppIds
        ];
        List<OpportunityLineItem> lineItems = [
            SELECT OpportunityId, Quantity, UnitPrice, TotalPrice
            FROM OpportunityLineItem
            WHERE OpportunityId IN :oppIds
        ];

        Map<Id, String> summaries = new Map<Id, String>();

        for (Opportunity opp : oppList) {
            Decimal total = 0;
            Integer itemCount = 0;

            for (OpportunityLineItem li : lineItems) {
                if (li.OpportunityId == opp.Id) {
                    total += li.Quantity * li.UnitPrice;
                    itemCount++;
                }
            }

            summaries.put(opp.Id, opp.Name + ': ' + itemCount + ' items, total ' + total);
        }

        return summaries;
    }

    /**
     * Calculates the average deal size for a set of opportunities.
     * Used for pipeline reporting: it divides the combined Amount of
     * all given opportunities by the number of opportunities, giving
     * sales managers a benchmark for typical deal value.
     * @param opps The opportunities to average
     * @return The average Amount per opportunity
     */
    public static Decimal averageDealSize(List<Opportunity> opps) {
        Decimal total = 0;
        for (Opportunity o : opps) {
            total += o.Amount;
        }
        return total / opps.size();
    }
}