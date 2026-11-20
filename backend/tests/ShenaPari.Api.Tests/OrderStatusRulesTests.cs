using ShenaPari.Api.Entities;
using ShenaPari.Api.Orders;
using static ShenaPari.Api.Entities.OrderStatus;

namespace ShenaPari.Api.Tests;

/// Pure unit tests: the order lifecycle without a server or a database.
public class OrderStatusRulesTests
{
    [Theory]
    [InlineData(Paid, Accepted)]
    [InlineData(Paid, Cancelled)]
    [InlineData(Accepted, Cooking)]
    [InlineData(Accepted, Cancelled)]
    [InlineData(Cooking, Ready)]
    [InlineData(Cooking, Cancelled)] // the kitchen ran out of something
    [InlineData(Ready, PickedUp)]
    [InlineData(Ready, NotPickedUp)]
    public void Allowed_transitions(OrderStatus from, OrderStatus to) =>
        Assert.True(OrderStatusRules.CanMove(from, to));

    [Theory]
    [InlineData(Paid, Cooking)]      // must be accepted first
    [InlineData(Paid, Ready)]
    [InlineData(Paid, PickedUp)]
    [InlineData(Accepted, Ready)]
    [InlineData(Cooking, PickedUp)]
    [InlineData(Ready, Cancelled)]
    [InlineData(Ready, Cooking)]     // no way back
    public void Forbidden_transitions(OrderStatus from, OrderStatus to) =>
        Assert.False(OrderStatusRules.CanMove(from, to));

    [Theory]
    [InlineData(PickedUp)]
    [InlineData(Cancelled)]
    [InlineData(NotPickedUp)]
    public void Final_statuses_lead_nowhere(OrderStatus final)
    {
        foreach (var to in Enum.GetValues<OrderStatus>())
            Assert.False(OrderStatusRules.CanMove(final, to));
        Assert.False(OrderStatusRules.IsActive(final));
    }

    [Fact]
    public void Eta_options_are_5_10_15_20() =>
        Assert.Equal([5, 10, 15, 20], OrderStatusRules.EtaOptions);

    [Theory]
    [InlineData(Paid, true)]
    [InlineData(Accepted, true)]
    [InlineData(Cooking, false)] // the food is being made: only the kitchen may stop it
    [InlineData(Ready, false)]
    public void The_customer_cancels_only_before_cooking(OrderStatus status, bool allowed) =>
        Assert.Equal(allowed, OrderStatusRules.CustomerCanCancel(status));
}
