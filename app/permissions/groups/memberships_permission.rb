module Groups::MembershipsPermission

  protected

  def may_create_memberships?(group=@group)
    logged_in? and
    current_user.may?(:admin, group)
  end
  alias_method :may_review_memberships?, :may_create_memberships?
  alias_method :may_review_groups_memberships?, :may_create_memberships?

  def may_join_memberships?(group=@group)
    logged_in? and
    (current_user.may?(:admin, group) or group.open_membership?)
  end

  # for now, there is only an edit ui for committees
  def may_edit_memberships?(group=@group)
    may_create_memberships? and group.committee?
  end

  def may_list_memberships?(group=@group)
    group.has_access? :see_members or
    (group.committee? && may_list_memberships?(group.parent))
  end

  def may_update_memberships?(group=@group)
    current_user.may?(:admin, group) and group.committee?
  end

  def may_leave_memberships?(group = @group)
    logged_in? and
    current_user.direct_member_of?(group) and
    (group.network? or group.users.uniq.size > 1)
  end

  def may_destroy_memberships?(membership = @membership)
    group = membership.group
    # user = membership.user

    # this is the strict way of doing it:
    # group.council != group and
    # group.council.full_council_powers? and
    # current_user.may?(:admin, group) and
    # user != current_user and
    # !user.may?(:admin, group) # can't destroy other admins

    # for now, be flexible:
    current_user.may?(:admin, group)
  end

  def may_create_remove_user_requests?(membership = @membership)
    # TODO: fix all the issues with these requests so that voting on user removal works
    return false

    group = membership.group
    user = membership.user

    # has to have a council
    group.council != group and
    current_user.may?(:admin, group) and
    user != current_user and
    RequestToRemoveUser.for_user(user).for_group(group).blank?
  end
end
