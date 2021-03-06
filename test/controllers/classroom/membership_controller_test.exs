defmodule Classlab.Classroom.MembershipControllerTest do
  alias Classlab.{Invitation, Membership}
  use Classlab.ConnCase

  setup %{conn: conn} do
    user = Factory.insert(:user)
    event = Factory.insert(:event)
    Factory.insert(:membership, event: event, user: user, role_id: 1)
    {:ok, conn: Session.login(conn, user), event: event}
  end

  describe "#index" do
    test "lists all entries on index where current user is not owner", %{conn: conn, event: event} do
      membership = Factory.insert(:membership, event: event, user: current_user(conn), role_id: 3)
      conn = get conn, classroom_membership_path(conn, :index, membership.event)
      assert html_response(conn, 200) =~ membership.user.email
    end

    test "shows nothing if user is owner of an event", %{conn: conn, event: event} do
      conn = get conn, classroom_membership_path(conn, :index, event)
      refute html_response(conn, 200) =~ "Delete"
    end
  end

  describe "#update" do
    test "changes role", %{conn: conn, event: event} do
      membership = Factory.insert(:membership, event: event, user: current_user(conn), role_id: 3)
      conn = put conn, classroom_membership_path(conn, :update, event, membership, role_id: 2)
      assert redirected_to(conn) == classroom_membership_path(conn, :index, event)
      assert Repo.get(Membership, membership.id).role_id == 2
    end
  end

  describe "#delete" do
    test "deletes chosen resource", %{conn: conn, event: event} do
      membership = Factory.insert(:membership, event: event, user: current_user(conn), role_id: 3)
      conn = delete conn, classroom_membership_path(conn, :delete, membership.event, membership)
      assert redirected_to(conn) == classroom_membership_path(conn, :index, membership.event)
      refute Repo.get(Membership, membership.id)
    end

    test "deletes invitation if existing", %{conn: conn, event: event} do
      membership = Factory.insert(:membership, event: event, user: current_user(conn), role_id: 3)
      invitation = Factory.insert(:invitation, event: event, email: current_user(conn).email, role_id: 3)
      conn = delete conn, classroom_membership_path(conn, :delete, membership.event, membership)
      assert redirected_to(conn) == classroom_membership_path(conn, :index, membership.event)
      refute Repo.get(Membership, membership.id)
      refute Repo.get(Invitation, invitation.id)
    end

    test "deletes invitation if only attendee and own membership", %{conn: conn} do
      event = Factory.insert(:event)
      membership = Factory.insert(:membership, event: event, user: current_user(conn), role_id: 3)
      conn = delete conn, classroom_membership_path(conn, :delete, event, membership)
      assert redirected_to(conn) == account_membership_path(conn, :index)
    end

    test "not deletes invitation if only attendee and not own membership", %{conn: conn} do
      event = Factory.insert(:event)
      other_membership = Factory.insert(:membership, event: event, role_id: 3)
      membership = Factory.insert(:membership, event: event, user: current_user(conn), role_id: 3)
      conn = delete conn, classroom_membership_path(conn, :delete, event, other_membership)
      assert redirected_to(conn) == classroom_membership_path(conn, :index, membership.event)
      assert get_flash(conn, :error) =~ "Permission denied"
    end
  end
end
