require File.expand_path('../../test_helper', __FILE__)

class ModelTest < GameThrive::UnitTest

  def setup
    @model = GameThrive::Model.new
    @model.class.class_eval do
      attribute :variable
      attribute :second
      attribute :custom, "CUSTOM"
    end
  end

  def test_self_attribute
    assert @model.class.instance_methods.include?("variable")
    assert @model.class.instance_methods.include?("variable=")
    assert @model.class.instance_methods.include?("variable_changed?")
    assert @model.class.instance_methods.include?("custom")
    assert @model.class.instance_methods.include?("custom=")
    assert @model.class.instance_methods.include?("custom_changed?")

    attribute_mapping = @model.class.send(:class_variable_get, :@@attribute_mapping)
    assert_equal "CUSTOM", attribute_mapping[:custom]
  end

  def test_new
    assert_equal [], @model.send(:changed_attributes)
    assert_equal({}, @model.attributes)

    instance = GameThrive::Model.new(:variable => "CHANGED")
    assert_equal "CHANGED", instance.variable
    assert_equal [:variable], instance.send(:changed_attributes)
  end

  def test_reset_changed_attributes
    @model.variable = "CHANGED"
    assert_equal [:variable], @model.send(:changed_attributes)
    @model.reset_changed_attributes!
    assert_equal [], @model.send(:changed_attributes)
  end

  def test_dirty?
    assert !@model.dirty?
    @model.variable = "CHANGED"
    assert @model.dirty?
  end

  def test_attributes_for_api
    @model.variable = "CHANGED"
    @model.reset_changed_attributes!
    @model.second = "CHANGED"
    @model.custom = "CUSTOM CHANGED"
    assert_equal({ "second" => "CHANGED", "CUSTOM" => "CUSTOM CHANGED" }, @model.attributes_for_api)
  end

  def test_assign_attributes
    @model.second = "SECOND"
    @model.send(:assign_attributes, { :variable => "CHANGED" })
    assert_equal "CHANGED", @model.variable
    assert_nil @model.second
    assert @model.dirty?

    setup

    @model.second = "SECOND"
    @model.send(:assign_attributes, { :variable => "CHANGED AGAIN" }, :reset => false)
    assert_equal "CHANGED AGAIN", @model.variable
    assert_equal "SECOND", @model.second
  end

  def test_reset_attributes
    @model.variable = "CHANGED"
    @model.send(:reset_attributes!)
    assert_nil @model.variable
  end

  def test_write_attribute
    @model.send(:write_attribute, :variable, "CHANGED")
    assert_equal "CHANGED", @model.variable
    assert @model.variable_changed?
  end

  def test_read_attribute
    @model.variable = "CHANGED"
    assert_equal "CHANGED", @model.send(:read_attribute, :variable)
  end

end
