#! /usr/bin/env python
# -*- coding: utf-8 -*-
# Author: AxiaCore S.A.S. http://axiacore.com
import optparse
from time import strptime
import getpass

from jira.client import JIRA


def parse_params():
    parser = optparse.OptionParser()
    parser.add_option(
        '-d',
        '--date',
        dest='date_',
        help=u'Fecha para la que se desea obtener el reporte '
        u'(formato yyyy-mm-dd)',
        action="store",
        type="string",
    )
    parser.add_option(
        '-u',
        '--username',
        dest='username',
        help=u'Usuario con el cual conectarse a JIRA',
        action="store",
        type="string",
    )
    parser.add_option(
        '-w',
        '--password',
        dest='password',
        help=u'Contraseña para acceder a JIRA',
        action="store",
        type="string",
    )
    options, _ = parser.parse_args()
    if any([o is None for o in [
        options.date_,
        options.username,
    ]]):
        parser.print_help()
        parser.error('Todas las opciones son obligatorias')
    try:
        strptime(options.date_, '%Y-%m-%d')
    except ValueError:
        parser.error(u'Fecha inválida: {}'.format(options.date_))
    return options


def show_indicator(failed_issues, good_issues, indicator_name, status_name):
    good_points = sum([
        float(issue.fields().customfield_10004 or 0)
        for issue in good_issues
    ])
    failed_points = sum([
        float(issue.fields().customfield_10004 or 0)
        for issue in failed_issues
    ])
    if failed_issues:
        print '-- Puntos en {}: {}'.format(status_name, failed_points)
        print '-- Indicador {}: {}'.format(
            indicator_name,
            failed_points / (failed_points + good_points),
        )


def main():
    options = {
        'server': 'https://axiacore.atlassian.net'
    }
    args = parse_params()

    if args.password is None:
        args.password = getpass.getpass()
    jira = JIRA(basic_auth=(args.username, args.password), options=options)
    date = args.date_

    points_at_axiacore = 0
    points_per_person = {}
    query_template = (
        'project = "%s" AND status CHANGED '
        'FROM "Quality Assurance" TO Review ON "%s" '
        'and "Story Points" IS NOT NULL'
    )
    reprocess_template = (
        'project = "%s" AND status CHANGED '
        'FROM "Quality Assurance" TO "In Progress" ON "%s" '
        'and "Story Points" IS NOT NULL'
    )
    finished_template = (
        'project = "%s" AND status CHANGED '
        'FROM "Review" TO "Done" ON "%s" '
        'and "Story Points" IS NOT NULL'
    )
    stopped_template = (
        'project = "%s" AND status CHANGED '
        'FROM "Review" TO "Stopped" ON "%s" '
        'and "Story Points" IS NOT NULL'
    )
    for project in jira.projects():
        issues = jira.search_issues(query_template % (project.key, date))
        points_per_project = 0.0
        if issues:
            print '* %s' % project.name.encode('utf-8')
            for issue in issues:
                # Story Points field is customfield_10004
                points = issue.fields().customfield_10004
                user = issue.fields().assignee.displayName
                points_per_project += points

                str_line = '%s\tPuntos: %s\t%s' % (
                    issue.key,
                    points,
                    user,
                )
                print str_line.encode('utf-8')

                if user in points_per_person:
                    points_per_person[user] += issue.fields().customfield_10004
                else:
                    points_per_person[user] = issue.fields().customfield_10004

            print '-- Total puntos: %s' % points_per_project
            points_at_axiacore += points_per_project

        show_indicator(jira.search_issues(
            reprocess_template % (project.key, date),
        ), issues, 'QA->Progress', 'Progress')

        show_indicator(jira.search_issues(
            stopped_template % (project.key, date),
        ), jira.search_issues(
            finished_template % (project.key, date),
        ), 'Review->Stopped', 'Stopped')

    print '**Puntos totales por persona:'
    for key in points_per_person.keys():
        print key.encode('utf-8'), points_per_person[key]
    print 'Total puntos en axiacore: %s' % points_at_axiacore

if __name__ == '__main__':
    main()
