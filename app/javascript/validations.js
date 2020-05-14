$(function() {
    $(document).on('submit', '#add_vanity_form', function() {
        path = $('.path', this).val();
        target = $('.target', this).val();
        if(!target.startsWith('/') || !path.startsWith('/')) {
            alert('Path and target both need to start with a /');
            return false;
        }
    });
});
