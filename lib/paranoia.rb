module Paranoia
  def self.included(klazz)
    klazz.extend Query
  end

  module Query
    def paranoid? ; true ; end

    def only_deleted
      unscoped {
        where('is_deleted' => 'Y')
      }
    end
  end

  def destroy
    _run_destroy_callbacks { delete }
  end

  def delete    
    self.update_attribute(:is_deleted, 'Y') if !deleted? && persisted?
    freeze
  end
  
  def restore!
    update_attribute :is_deleted, nil
  end

  def destroyed?
    self.is_deleted == 'Y'
  end
  alias :deleted? :destroyed?
end

class ActiveRecord::Base
  def self.acts_as_paranoid
    alias_method :destroy!, :destroy
    alias_method :delete!,  :delete
    include Paranoia
    t = arel_table
    default_scope where(t[:is_deleted].eq(nil).or(t[:is_deleted].eq('N')))
  end

  def self.paranoid? ; false ; end
  def paranoid? ; self.class.paranoid? ; end
end
