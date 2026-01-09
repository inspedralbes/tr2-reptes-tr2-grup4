require "test_helper"

class PisControllerTest < ActionDispatch::IntegrationTest
  setup do
    @pi = pis(:one)
  end

  test "should get index" do
    get pis_url, as: :json
    assert_response :success
  end

  test "should create pi" do
    assert_difference("Pi.count") do
      post pis_url, params: { pi: { activities: @pi.activities, description: @pi.description, interacttutorial: @pi.interacttutorial, medrec: @pi.medrec, observations: @pi.observations } }, as: :json
    end

    assert_response :created
  end

  test "should show pi" do
    get pi_url(@pi), as: :json
    assert_response :success
  end

  test "should update pi" do
    patch pi_url(@pi), params: { pi: { activities: @pi.activities, description: @pi.description, interacttutorial: @pi.interacttutorial, medrec: @pi.medrec, observations: @pi.observations } }, as: :json
    assert_response :success
  end

  test "should destroy pi" do
    assert_difference("Pi.count", -1) do
      delete pi_url(@pi), as: :json
    end

    assert_response :no_content
  end
end
