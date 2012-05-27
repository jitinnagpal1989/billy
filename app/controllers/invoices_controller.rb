class InvoicesController < ApplicationController
  def index
    @invoices = Invoice.all.order_by([:number, :desc])
    @totals = InvoiceTotalsInfo.new(@invoices.sum(:taxable_income), @invoices.sum(:tax), @invoices.sum(:total))
  end

  def new
    @invoice = Invoice.create_new
    @invoice.customer = Customer.new
    @invoice.has_tax = true
    @customers = Customer.all #.map{|c| [c.name, c._id]}
  end

  def create
    @invoice = Invoice.new(params[:invoice])
    @invoice.customer = Customer.find(params[:invoice][:customer_id])
    @invoice.invoice_items = @invoice.invoice_items.delete_if {|i| i.description.empty?}
    @invoice.save
    redirect_to invoices_path
  end

  def edit  
    @invoice = Invoice.find(params[:id])
    @customers = Customer.all #.map{|c| [c.name, c._id]}
  end

  def update  
    @invoice = Invoice.find(params[:id])
    @invoice.update_attributes!(params[:invoice])
    redirect_to invoices_path
  end

end
