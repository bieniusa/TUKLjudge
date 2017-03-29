<small class="text-muted" style="float: right">
	TUKLjudge version <?php echo TUKLJUDGE_VERSION; ?>, a fork of DOMjudge version <?php echo DOMJUDGE_VERSION; ?>
	<a href="../public/changelog.php">Imprint / Changelog</a>
</small>

</div>

<?php
/**
 * Common page footer
 */
if (!defined('DOMJUDGE_VERSION')) die("DOMJUDGE_VERSION not defined.");

if ( DEBUG & DEBUG_TIMINGS ) {
	echo "<p>"; totaltime(); echo "</p>";
} ?>

</body>
</html>
